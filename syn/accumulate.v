module accumulate #(
  parameter N = 2,
  parameter W = 16
)(
  input clk,
  input rst,

  input [N-1:0] arg_stb,
  input [N*W-1:0] arg_dat,
  output reg [N-1:0] arg_rdy,

  output res_stb,
  output [W-1:0] res_dat,
  input res_rdy
);
  localparam RES_MAX = 2**(W-1)-1;
  localparam RES_MIN = -(2**(W-1));

  reg [W:0] acc = 0;

  integer n;
  always @ (*) begin
    arg_rdy = 0;
    for (n = N - 1; n >= 0; n = n - 1) begin
      if (arg_stb[n]) begin
        arg_rdy = 0;
        arg_rdy[n] = 1;
      end
    end
  end

 endmodule
