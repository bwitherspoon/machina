module serialize #(
  parameter ARGW = 16,
  parameter ARGN = 2
)(
  input clk,
  input rst,

  input [ARGN-1:0] arg_stb,
  input [ARGN*ARGW-1:0] arg_dat,
  output [ARGN-1:0] arg_rdy,

  output reg res_stb,
  output reg [$clog2(ARGN)+ARGW-1:0] res_dat,
  input res_rdy
);
  wire arg_ack = |arg_stb & |arg_rdy;
  wire res_ack = res_stb & res_rdy;
  wire res_bsy = res_stb & ~res_rdy;
  reg [$clog2(ARGN)-1:0] arg_sel;
  reg [ARGN-1:0] arg_flg = 0;

  assign arg_rdy = (res_bsy) ? 0 : 1 << arg_sel;

  integer n;
  always @* begin
    arg_sel = 0;
    for (n = ARGN - 1; n > 0; n = n - 1) begin
      if (~arg_flg[n] & arg_stb[n])
        arg_sel = n[$clog2(ARGN)-1:0];
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      arg_flg <= 0;
    end else if (arg_ack) begin
      arg_flg <= arg_flg | arg_rdy;
    end
  end

  initial res_stb = 0;
  always @(posedge clk) begin
    if (rst) begin
      res_stb <= 0;
    end else if (arg_ack & !res_bsy) begin
      res_stb <= 1;
      res_dat <= {arg_sel, arg_dat[ARGW*arg_sel+:ARGW]};
    end else if (res_ack) begin
      res_stb <= 0;
    end
  end

 endmodule
