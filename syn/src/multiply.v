module multiply #(
  parameter ARGW = 16
)(
  input clk,
  input rst,

  input arg_stb,
  input [2*ARGW-1:0] arg_dat,
  output arg_rdy,

  output reg res_stb,
  output reg [2*ARGW-1:0] res_dat,
  input res_rdy
);
  wire arg_ack = arg_stb & arg_rdy;
  wire res_ack = res_stb & res_rdy;
  wire res_bsy = res_stb & ~res_rdy;

  reg signed [ARGW-1:0] arg [1:0];
  reg mul_stb = 0;

  assign arg_rdy = ~mul_stb | res_rdy;

  always @(posedge clk) begin
    if (arg_ack) begin
      arg[0] <= arg_dat[0+:ARGW];
      arg[1] <= arg_dat[ARGW+:ARGW];
    end
  end

  initial res_stb = 0;
  always @(posedge clk) begin
    if (rst) begin
      res_stb <= 0;
    end else if (mul_stb) begin
      if (~res_stb) begin
        res_stb <= 1;
        res_dat <= arg[0] * arg[1];
      end
    end else if (res_ack) begin
      res_stb <= 0;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      mul_stb <= 0;
    end else if (~mul_stb & arg_ack) begin
      mul_stb <= 1;
    end else if (mul_stb & ~res_bsy) begin
      mul_stb <= 0;
    end
  end

endmodule
