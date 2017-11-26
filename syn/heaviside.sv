module heaviside (
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
  logic signed [15:0] argument;
  logic [15:0] delta;

`ifndef NOENUM
  enum logic [1:0] { ARG, RES, ERR, FBK } state = ARG;
`else
  localparam ARG = 2'd0;
  localparam RES = 2'd1;
  localparam ERR = 2'd2;
  localparam FBK = 2'd3;
  logic [1:0] state = ARG;
`endif

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
    if (arg_valid & arg_ready)
      argument <= arg_data;
  end

  always @ (posedge clock) begin
    if (state == RES) begin
      if (!res_valid) begin
        res_valid <= 1;
        res_data <= (argument < 0) ? 8'h00 : 8'hff;
      end else if (res_ready) begin
        res_valid <= 0;
      end
    end else begin
      res_valid <= 0;
    end
  end

  assign err_ready = state == ERR;

  always @ (posedge clock) begin
    if (err_valid & err_ready)
      delta <= err_data;
  end

  always @ (posedge clock) begin
    if (state == FBK) begin
      if (!fbk_valid) begin
        fbk_valid <= 1;
        fbk_data <= delta;
      end else if (fbk_ready) begin
        fbk_valid <= 0;
      end
    end else begin
      fbk_valid <= 0;
    end
  end

endmodule
