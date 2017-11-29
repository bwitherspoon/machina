module accumulate #(
  parameter WIDTH = 16,
  parameter DEPTH = 2
)(
  input clk,
  input rst,

  input [DEPTH-1:0] arg_stb,
  input [DEPTH*WIDTH-1:0] arg_dat,
  output reg [DEPTH-1:0] arg_rdy,

  output reg res_stb,
  output reg [DEPTH+WIDTH-1:0] res_dat,
  input res_rdy
);
  reg [DEPTH+WIDTH-1:0] acc = 0;

  integer n;
  always @ (*) begin
    arg_rdy = 0;
    for (n = DEPTH - 1; n >= 0; n = n - 1) begin
      if (arg_stb[n]) begin
        arg_rdy = 0;
        arg_rdy[n] = 1;
      end
    end
  end

  initial res_stb = 0;
  always @(posedge clk) begin
    if (rst) begin
      res_stb <= 0;
    end else if (!res_stb) begin
      res_stb <= 1;
      res_dat <= acc;
    end else if (res_rdy) begin
      res_stb <= 0;
    end
  end

  wire [DEPTH*WIDTH-1:0] unused =  arg_dat;

 endmodule
