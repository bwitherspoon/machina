module associate #(
  parameter NARG = 2,
  parameter RATE = 2,
  parameter SEED = 0
)(
  input logic clock,
  input logic reset,
  input logic train,

  input  logic argument_valid,
  input  logic [NARG-1:0][7:0] argument_data,
  output logic argument_ready,

  output logic result_valid,
  output logic [15:0] result_data,
  input  logic result_ready,

  input  logic error_valid,
  input  logic [15:0] error_data,
  output logic error_ready,

  output logic propagate_valid,
  output logic [NARG-1:0][15:0] propagate_data,
  input  logic propagate_ready
);
  localparam BITS = 8;
  localparam MAX = $signed(16'h7fff);
  localparam MIN = $signed(16'h8000);

  typedef logic signed [ 8:0] arg_t;
  typedef logic signed [15:0] res_t;
  typedef logic signed [23:0] ext_t;

  arg_t argument [NARG];
  res_t weight [NARG];
  res_t bias = 0;
  res_t delta = 0;

  logic [$bits(res_t)-1:0] propagation [NARG];

`ifndef NOENUM
  enum logic [3:0] { ARG, MUL, MAC, ACC, RES, DEL, ERR, PRP, UPD } state = ARG;
`else
  localparam ARG = 4'd0;
  localparam MUL = 4'd1;
  localparam MAC = 4'd2;
  localparam ACC = 4'd3;
  localparam RES = 4'd4;
  localparam DEL = 4'd5;
  localparam ERR = 4'd6;
  localparam PRP = 4'd7;
  localparam UPD = 4'd8;
  logic [3:0] state = ARG;
`endif

  // Cycle counter
  typedef logic [$clog2(NARG)-1:0] cnt_t;
  localparam CNT = cnt_t'(NARG - 1);
  cnt_t count = 0;
  always @(posedge clock) begin
    if (state == MUL || state == MAC || state == ERR || state == UPD) begin
      if (count == CNT) begin
        count <= 0;
      end else begin
        count <= count + 1;
      end
    end else begin
      count <= 0;
    end
  end

  // Initialize weights to small pseudorandom values or zero
`ifndef VERILATOR
  int seed = SEED;
  initial begin
    for (int n = 0; n < NARG; n = n + 1) begin
      weight[n] = res_t'($random(seed) % 2**(BITS-4));
    end
  end
`else
  initial begin
    for (int n = 0; n < NARG; n = n + 1) begin
      weight[n] = 0;
    end
  end
`endif

  assign argument_ready = state == ARG;
  genvar a;
  generate
    for (a = 0; a < NARG; a = a + 1) begin
      always @(posedge clock) begin
        if (argument_valid & argument_ready) begin
          argument[a] <= arg_t'(argument_data[a]);
        end
      end
    end
  endgenerate

  // Multiply and accumulate
  ext_t summand = 0;
  always @(posedge clock) begin
    if (state == MUL || state == MAC) begin
      summand <= ext_t'(weight[count]) * ext_t'(argument[count]) >>> BITS;
    end
  end

  // TODO overflow / underflow signals
  ext_t accumulator = 0;
  always @(posedge clock) begin
    if (reset) begin
      accumulator <= 0;
    end else if (state == ARG) begin
      accumulator <= ext_t'(bias);
    end else if (state == MAC || state == ACC) begin
      accumulator <= accumulator + summand;
    end
  end

  // Output inner product
  initial result_valid = 0;
  always @(posedge clock) begin
    if (state == RES) begin
      if (!result_valid) begin
        result_valid <= 1;
        result_data <= accumulator[$bits(result_data)-1:0];
      end else if (result_ready) begin
        result_valid <= 0;
      end
    end else begin
      result_valid <= 0;
    end
  end

  // Load delta
  assign error_ready = state == DEL;
  always @ (posedge clock) begin
    if (error_valid & error_ready) begin
      delta <= res_t'(error_data);
    end
  end

  // Compute and saturate errors
  ext_t err;
  assign err = ext_t'(weight[count]) * ext_t'(delta) >>> BITS;
  always @ (posedge clock) begin
    if (state == ERR) begin
      if (err < ext_t'(MIN))
        propagation[count] <= $unsigned(MIN);
      else if (err > ext_t'(MAX))
        propagation[count] <= $unsigned(MAX);
      else
        propagation[count] <= err[15:0];
    end
  end

  // Backward propagate errors
  initial propagate_valid = 0;
  always @ (posedge clock) begin
    if (state == PRP) begin
      if (!propagate_valid) begin
        propagate_valid <= 1;
      end else if (propagate_ready) begin
        propagate_valid <= 0;
      end
    end else begin
      propagate_valid <= 0;
    end
  end

  genvar p;
  generate
    for (p = 0; p < NARG; p = p + 1) begin
      always @ (posedge clock) begin
        if (state == PRP) begin
          propagate_data[p] <= propagation[p];
        end
      end
    end
  endgenerate

  // Update weights and bias
  // TODO overflow / underflow signals
  ext_t operand;
  ext_t product;
  res_t update;
  /* verilator lint_off WIDTH */
  assign operand = argument[count]; // FIXME
  /* verilator lint_on WIDTH */
  assign product = delta * operand >>> BITS + RATE;
  assign update = (product < ext_t'(MIN)) ? MIN : (product > ext_t'(MAX)) ? MAX : res_t'(product);
  always @ (posedge clock) begin
    if (state == UPD) begin
      weight[count] <= weight[count] + update;
    end
  end

  always @ (posedge clock) begin
    if (state == UPD && count == 0) begin
      bias <= bias + (delta >>> RATE);
    end
  end

  // State machine logic
  always @(posedge clock) begin
    if (reset) begin
      state <= ARG;
    end else begin
      case (state)
        ARG:
          if (argument_valid)
            state <= MUL;
        MUL:
          state <= MAC;
        MAC:
          if (count == CNT)
            state <= ACC;
        ACC:
          state <= RES;
        RES:
          if (result_valid & result_ready)
            state <= (train) ? DEL : ARG;
        DEL:
          if (error_valid & error_ready)
            state <= ERR;
        ERR:
          if (count == CNT)
            state <= PRP;
        PRP:
          if (propagate_valid & propagate_ready)
            state <= UPD;
        UPD:
          if (count == CNT)
            state <= ARG;
        default: begin
          $display("ERROR: %s:%0d invalid state: %0h", `__FILE__, `__LINE__, state);
          $stop;
        end
      endcase
    end
  end

endmodule
