module accumulate #(
  parameter ARGW = 32,
  parameter RESW = 40
)(
  input clk,
  input rst,
  input clr,

  input arg_stb,
  input [ARGW-1:0] arg_dat,
  output arg_rdy,

  output res_stb,
  output [RESW-1:0] res_dat,
  input res_rdy
);
  initial if (RESW < ARGW)
    $display("ERROR: accumulate: result width must be greater then or equal to argument width");

  reg signed [RESW-1:0] acc;
  reg signed [RESW-1:0] sum = 0;

  always @* begin
    if (clr) begin
      acc = 0;
    end else begin
      acc = sum;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      sum <= 0;
    end else if (arg_stb & arg_rdy) begin
      sum <= acc + $signed({{(RESW-ARGW){arg_dat[ARGW-1]}}, arg_dat});
    end
  end

  assign arg_rdy = ~res_stb | res_rdy;

  reg res_stb = 0;
  always @(posedge clk) begin
    if (rst) begin
      res_stb <= 0;
    end else if (!res_stb) begin
      res_stb <= 1;
    end else if (res_rdy) begin
      res_stb <= 0;
    end
  end

  assign res_dat = sum;

 endmodule
