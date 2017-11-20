module product #(
  parameter N = 2,
  parameter S = 2,
  parameter SEED = 0
)(
  input logic clock,
  input logic reset,
  input logic train,

  input  logic argument_valid,
  input  logic [N-1:0][7:0] argument_data,
  output logic argument_ready,

  output logic result_valid,
  output logic [15:0] result_data,
  input  logic result_ready,

  input  logic error_valid,
  input  logic [15:0] error_data,
  output logic error_ready,

  output logic propagate_valid,
  output logic [N-1:0][15:0] propagate_data,
  input  logic propagate_ready
);
  localparam W = 8;

  typedef logic signed [ 9:0] arg_t;
  typedef logic signed [15:0] res_t;
  typedef logic signed [23:0] ext_t;

  typedef logic [$clog2(N)-1:0] cnt_t;
  localparam CNT = cnt_t'(N - 1);
  cnt_t counter = 0;

  arg_t argument [N];
  res_t weight [N];
  res_t bias = 0;
  res_t delta = 0;
  ext_t summand = 0;
  ext_t accumulator = 0;

  logic [$bits(res_t)-1:0] errors [N];

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

  // Initialize weights to small pseudorandom values
`ifndef VERILATOR
  int seed = SEED;
  initial begin
    for (int n = 0; n < N; n = n + 1) begin
      weight[n] = res_t'($random(seed) % 2**(W-4));
    end
  end
`endif

  // Initialize arguments to zero
  initial begin
    for (int n = 0; n < N; n = n + 1) begin
      argument[n] = 0;
    end
  end

  // Load arguments
  assign argument_ready = state == ARG;
  genvar m;
  generate
    for (m = 0; m < N; m = m + 1) begin
      always @(posedge clock) begin
        if (argument_valid & argument_ready) begin
          argument[m] <= arg_t'(argument_data[m]);
        end
      end
    end
  endgenerate

  // Cycle counter
  always @(posedge clock) begin
    if (reset) begin
      counter <= 0;
    end else if (state == MUL || state == MAC || state == ERR || state == UPD) begin
      if (counter == CNT) begin
        counter <= 0;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  // Multiply and accumulate
  always @(posedge clock) begin
    if (state == MUL || state == MAC) begin
      summand <= ext_t'(weight[counter]) * ext_t'(argument[counter]) >>> W;
    end
  end

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
      bias <= bias + (res_t'(error_data) >>> S);
    end
  end

  // Compute error terms
  always @ (posedge clock) begin
    if (state == ERR)
      errors[counter] <= 16'(weight[counter] * delta >>> W);
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

  genvar k;
  generate
    for (k = 0; k < N; k = k + 1) begin
      always @ (posedge clock) begin
        if (state == PRP && propagate_valid != 1)
            propagate_data[k] <= errors[k];
      end
    end
  endgenerate

  // Update weights and bias
  // TODO reset
  // FIXME iverilog work around, fails verilator lint
  ext_t operand;
  res_t update;
  assign operand = delta;
  assign update = operand * argument[counter] >>> W + S;
  always @ (posedge clock) begin
    if (state == UPD) begin
      weight[counter] <= weight[counter] + update;
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
          if (counter == CNT)
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
          if (counter == CNT)
            state <= PRP;
        PRP:
          if (propagate_valid & propagate_ready)
            state <= UPD;
        UPD:
          if (counter == CNT)
            state <= ARG;
        default: begin
          $display("ERROR: %s:%0d invalid state: %0h", `__FILE__, `__LINE__, state);
          $stop;
        end
      endcase
    end
  end

endmodule
