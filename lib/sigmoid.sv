module sigmoid #(
  parameter RATE = 1.0
)(
  input logic clock,
  input logic reset,
  input logic train,

  input logic arg_valid,
  input logic [15:0] arg_data,
  output logic arg_ready,

  output logic res_valid,
  output logic [7:0] res_data,
  input logic res_ready,

  input logic err_valid,
  input logic [15:0] err_data,
  output logic err_ready,

  output logic fbk_valid,
  output logic [15:0] fbk_data,
  input logic fbk_ready
);
  function real f(int value);
    return 1.0 / (1.0 + $exp(-RATE * $itor(value) / 2.0**8));
  endfunction

  logic [7:0] activation [2**12];
  logic [7:0] result;
  logic [7:0] derivative;
  logic signed [15:0] error;

`ifndef NOENUM
  enum logic [1:0] { ARG, RES, ERR, FBK } state = ARG;
`else
  localparam ARG = 2'd0;
  localparam RES = 2'd1;
  localparam ERR = 2'd2;
  localparam FBK = 2'd3;
  logic [1:0] state = ARG;
`endif

  initial begin
    for (int n = -6 <<< 8; n < 6 <<< 8; n++)
      activation[n[11:0]] = 8'($rtoi(2.0**8 * f(n)));
  end

  always @ (posedge clock) begin
    case (state)
      ARG:
        if (arg_valid & arg_ready)
          state <= RES;
      RES:
        if (res_valid & res_ready)
          state <= (train) ? ERR : ARG;
      ERR:
        if (err_valid & err_ready)
          state <= FBK;
      FBK:
        if (fbk_valid & fbk_ready)
          state <= ARG;
    endcase
  end

  assign arg_ready = state == ARG;
  always @ (posedge clock) begin
    if (arg_valid & arg_ready) begin
      if ($signed(arg_data) >= 6 <<< 8)
        result <= 8'hff;
      else if ($signed(arg_data) < -6 <<< 8)
        result <= 8'h00;
      else
        result <= activation[arg_data[11:0]];
    end
  end

  always @ (posedge clock) begin
    if (state == RES) begin
      if (!res_valid) begin
        res_valid <= 1;
        res_data <= result;
      end else if (res_ready) begin
        res_valid <= 0;
      end
    end else begin
      res_valid <= 0;
    end
  end

  assign err_ready = state == ERR;
  always @ (posedge clock) begin
    if (err_valid & err_ready) begin
      error <= err_data;
      derivative <= result * (2**8 - result) >>> 8;
    end
  end

  always @ (posedge clock) begin
    if (state == FBK) begin
      if (!fbk_valid) begin
        fbk_valid <= 1;
        fbk_data <= error * $signed({1'b0, derivative}) >>> 8;
      end else if (fbk_ready) begin
        fbk_valid <= 0;
      end
    end else begin
      fbk_valid <= 0;
    end
  end

endmodule
