module associate #(
  parameter N = 2,
  parameter RATE = 2,
  parameter SEED = 0
)(
  input logic clock,
  input logic reset,
  input logic train,

  input  logic arg_valid,
  input  logic [N-1:0][7:0] arg_data,
  output logic arg_ready,

  output logic res_valid,
  output logic [15:0] res_data,
  input  logic res_ready,

  input  logic err_valid,
  input  logic [15:0] err_data,
  output logic err_ready,

  output logic fbk_valid,
  output logic [N-1:0][15:0] fbk_data,
  input  logic fbk_ready
);
  localparam W = 8;
  localparam MAX = $signed(16'h7fff);
  localparam MIN = $signed(16'h8000);

  typedef logic signed [ 8:0] arg_t;
  typedef logic signed [15:0] res_t;
  typedef logic signed [23:0] mac_t;

  arg_t argument [N];
  res_t weight [N];
  res_t bias = 0;
  res_t delta = 0;

  logic [$bits(res_t)-1:0] feedback [N];

`ifndef NOENUM
  enum logic [3:0] { ARG, MUL, MAC, ACC, RES, DEL, ERR, FBK, UPD } state = ARG;
`else
  localparam ARG = 4'd0;
  localparam MUL = 4'd1;
  localparam MAC = 4'd2;
  localparam ACC = 4'd3;
  localparam RES = 4'd4;
  localparam DEL = 4'd5;
  localparam ERR = 4'd6;
  localparam FBK = 4'd7;
  localparam UPD = 4'd8;
  logic [3:0] state = ARG;
`endif

  // Cycle counter
  typedef logic [$clog2(N)-1:0] cnt_t;
  localparam CNT = cnt_t'(N - 1);
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
    for (int n = 0; n < N; n = n + 1) begin
      weight[n] = res_t'($random(seed) % 2**(W-4));
    end
  end
`else
  initial begin
    for (int n = 0; n < N; n = n + 1) begin
      weight[n] = 0;
    end
  end
`endif

  assign arg_ready = state == ARG;
  genvar m;
  generate
    for (m = 0; m < N; m = m + 1) begin
      always @(posedge clock) begin
        if (arg_valid & arg_ready) begin
          argument[m] <= arg_t'(arg_data[m]);
        end
      end
    end
  endgenerate

  // Multiply and accumulate
  mac_t summand = 0;
  always @(posedge clock) begin
    if (state == MUL || state == MAC) begin
      summand <= mac_t'(weight[count]) * mac_t'(argument[count]) >>> W;
    end
  end

  // TODO overflow / underflow signals
  mac_t accumulator = 0;
  mac_t accumulation;
  assign accumulation = accumulator + summand;
  always @(posedge clock) begin
    if (reset) begin
      accumulator <= 0;
    end else if (state == ARG) begin
      accumulator <= mac_t'(bias);
    end else if (state == MAC || state == ACC) begin
      if (accumulation < mac_t'(MIN))
        accumulator <= mac_t'(MIN);
      else if (accumulation > mac_t'(MAX))
        accumulator <= mac_t'(MAX);
      else
        accumulator <= accumulation;
    end
  end

  // Output inner product
  initial res_valid = 0;
  always @(posedge clock) begin
    if (state == RES) begin
      if (!res_valid) begin
        res_valid <= 1;
        res_data <= accumulator[$bits(res_data)-1:0];
      end else if (res_ready) begin
        res_valid <= 0;
      end
    end else begin
      res_valid <= 0;
    end
  end

  // Load delta
  assign err_ready = state == DEL;
  always @ (posedge clock) begin
    if (err_valid & err_ready) begin
      delta <= res_t'(err_data);
    end
  end

  // Evaluate and saturate errors
  mac_t error;
  assign error = mac_t'(weight[count]) * mac_t'(delta) >>> W;
  always @ (posedge clock) begin
    if (state == ERR) begin
      if (error < mac_t'(MIN))
        feedback[count] <= $unsigned(MIN);
      else if (error > mac_t'(MAX))
        feedback[count] <= $unsigned(MAX);
      else
        feedback[count] <= error[15:0];
    end
  end

  // Backward propagate errors
  initial fbk_valid = 0;
  always @ (posedge clock) begin
    if (state == FBK) begin
      if (!fbk_valid) begin
        fbk_valid <= 1;
      end else if (fbk_ready) begin
        fbk_valid <= 0;
      end
    end else begin
      fbk_valid <= 0;
    end
  end

  genvar k;
  generate
    for (k = 0; k < N; k = k + 1) begin
      always @ (posedge clock) begin
        if (state == FBK) begin
          fbk_data[k] <= feedback[k];
        end
      end
    end
  endgenerate

  // Update weights and bias
  // TODO handle overflow / underflow in addition
  mac_t operand;
  mac_t product;
  res_t update;
  // FIXME workaround for icarus verilog
  /* verilator lint_off WIDTH */
  assign operand = argument[count];
  /* verilator lint_on WIDTH */
  assign product = delta * operand >>> W + RATE;
  assign update = (product < mac_t'(MIN)) ? MIN : (product > mac_t'(MAX)) ? MAX : res_t'(product);
  always @ (posedge clock) begin
    if (reset) begin
      for (int n = 0; n < N; n = n + 1) weight[n] = 0;
    end else if (state == UPD) begin
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
          if (arg_valid)
            state <= MUL;
        MUL:
          state <= MAC;
        MAC:
          if (count == CNT)
            state <= ACC;
        ACC:
          state <= RES;
        RES:
          if (res_valid & res_ready)
            state <= (train) ? DEL : ARG;
        DEL:
          if (err_valid & err_ready)
            state <= ERR;
        ERR:
          if (count == CNT)
            state <= FBK;
        FBK:
          if (fbk_valid & fbk_ready)
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
