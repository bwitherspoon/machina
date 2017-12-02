module multiply #(
  parameter W = 16,
  parameter Q = 8
)(
  input clk,
  input rst,

  input arg_stb,
  input [2*W-1:0] arg_dat,
  output arg_rdy,

  output res_stb,
  output [2*W-Q-1:0] res_dat,
  input res_rdy
);
  initial begin
    if (Q < 1) begin
      $display("ERROR: multiply.v: Q must be non-negative and non-zero");
      $finish;
    end
    if (Q > W) begin
      $display("ERROR: multiply.v: Q must be less than or equal to W");
      $finish;
    end
    if (W < 0) begin
      $display("ERROR: multiply.v: W must be non-negative");
      $finish;
    end
  end

  wire arg_ack = arg_stb & arg_rdy;
  wire res_ack = res_stb & res_rdy;
  wire res_bsy = res_stb & ~res_rdy;

  reg signed [W-1:0] arg [1:0];
  reg signed [2*W-1:0] mul_dat;
  reg mul_stb = 0;
  reg res_stb = 0;

  assign arg_rdy = ~mul_stb | res_rdy;

  always @(posedge clk) begin
    if (arg_ack) begin
      arg[0] <= arg_dat[0+:W];
      arg[1] <= arg_dat[W+:W];
    end
  end

  if (Q > 0) wire [Q-1:0] unused = mul_dat[Q-1:0];
  assign res_dat = mul_dat[2*W-1:Q];

  always @(posedge clk) begin
    if (rst) begin
      res_stb <= 0;
    end else if (mul_stb) begin
      if (~res_stb) begin
        res_stb <= 1;
        mul_dat <= arg[0] * arg[1];
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
