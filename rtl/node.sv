module node #(
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
  typedef logic signed [W:0] std_t;
  typedef logic signed [2*$bits(std_t)-1:0] ext_t;

  typedef logic [$clog2(N)-1:0] cnt_t;
  localparam CNT = cnt_t'(N - 1);
  cnt_t counter;

  std_t argument [N];
  ext_t weight [N];
  ext_t bias = 0;
  ext_t summand = 0;
  ext_t accumulator = 0;
  ext_t delta = 0;

  logic [15:0] propagate [N];

`ifndef NOENUM
  enum logic [3:0] { ARG, MUL, MAC, ACC, RES, DEL, ERR, FBK, UPD } state;
`else
  localparam ARG = 2'd0;
  localparam MUL = 2'd1;
  localparam MAC = 2'd2;
  localparam ACC = 2'd3;
  localparam RES = 2'd4;
  localparam DEL = 2'd5;
  localparam ERR = 2'd6;
  localparam FBK = 2'd7;
  localparam UPD = 2'd8;
  logic [3:0] state = ARG;
`endif

  // Initialize weights to small pseudorandom values and arguments to zero
  int seed = SEED;
  initial begin
    for (int i = 0; i < N; i = i + 1) begin
`ifndef VERILATOR
      weight[i] = ext_t'($random(seed) % 2**4);
`else
      weight[i] = '0;
`endif
      argument[i] = '0;
    end
  end

  // Load arguments
  assign argument_ready = state == ARG;

  genvar n;
  generate
    for (n = 0; n < N; n = n + 1) begin
      always @(posedge clock) begin
        if (argument_valid & argument_ready) begin
          argument[n] <= std_t'(argument_data[n]);
        end
      end
    end
  endgenerate

  // Cycle counter
  always @(posedge clock) begin
    if (reset) begin
      counter <= '0;
    end else if (state == MUL || state == MAC || state == ERR || state == UPD) begin
      if (counter == CNT) begin
        counter <= '0;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  // Multiply and accumulate
  always @(posedge clock) begin
    if (state == MUL || state == MAC) begin
      summand <= (weight[counter] * argument[counter]) >>> W;
    end
  end

  always @(posedge clock) begin
    if (reset) begin
      accumulator <= '0;
    end else if (state == ARG) begin
      accumulator <= bias;
    end else if (state == MAC || state == ACC) begin
      accumulator <= accumulator + summand;
    end
  end

  // Output cross product
  always @(posedge clock) begin
    if (reset) begin
      result_valid <= '0;
    end else if (state == RES) begin
      if (!result_valid) begin
        result_valid <= '1;
        result_data <= accumulator[15:0];
      end else if (result_ready) begin
        result_valid <= '0;
      end
    end
  end

  // Load error
  assign error_ready = state == DEL;

  always @ (posedge clock) begin
    if (error_valid & error_ready)
      delta <= ext_t'($signed(error_data));
  end

  // Compute error terms
  always @ (posedge clock) begin
    if (state == ERR)
      propagate[counter] <= 16'(weight[counter] * delta >>> W);
  end

  // Backward propagate errors
  always @ (posedge clock) begin
    if (reset) begin
      propagate_valid <= '0;
    end else if (state == FBK) begin
      if (!propagate_valid) begin
        propagate_valid <= '1;
      end else if (propagate_ready) begin
        propagate_valid <= '0;
      end
    end
  end

  genvar k;
  generate
    for (k = 0; k < N; k = k + 1) begin
      always @ (posedge clock) begin
        if (state == FBK && propagate_valid != '1)
            propagate_data[k] <= propagate[k];
      end
    end
  endgenerate

  // Update weights and bias
  // TODO reset
  always @ (posedge clock) begin
    if (state == UPD) begin
      weight[counter] <= weight[counter] + (delta * argument[counter] >>> S + W);
      bias <= bias + (delta >>> S);
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
            state <= FBK;
        FBK:
          if (propagate_valid & propagate_ready)
            state <= UPD;
        UPD:
          if (counter == CNT)
            state <= ARG;
        default:
          $fatal(0, "invalid state: %h", state);
      endcase
    end
  end

endmodule
