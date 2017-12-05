module accumulate #(
  parameter ARGW = 32,
  parameter RESW = 40
)(
  input clk,
  input rst,

  input arg_stb,
  input [ARGW-1:0] arg_dat,
  output arg_rdy,

  output reg res_stb,
  output reg [RESW-1:0] res_dat,
  input res_rdy
);
  initial if (RESW < ARGW)
    $display("ERROR: accumulate: result width must be greater then or equal to argument width");

  reg arg_ack = 0;
  reg arg_end = 0;
  reg signed [RESW-1:0] acc = 0;

  assign arg_rdy = ~res_stb | res_rdy;

  always @(posedge clk) begin
    if (rst)
      arg_ack <= 0;
    else
      arg_ack <= arg_stb & arg_rdy;
  end

  always @(posedge clk) begin
    if (rst | arg_end)
      arg_end <= 0;
    else
      arg_end <= arg_ack & ~arg_stb;
  end

  always @(posedge clk) begin
    if (rst | arg_end) begin
      acc <= 0;
    end else if (arg_stb & arg_rdy) begin
      acc <= acc + $signed({{(RESW-ARGW){arg_dat[ARGW-1]}}, arg_dat});
    end
  end

  initial res_stb = 0;
  always @(posedge clk) begin
    if (rst) begin
      res_stb <= 0;
    end else if (~res_stb) begin
      if (arg_end) begin
        res_stb <= 1;
        res_dat <= acc;
      end
    end else if (res_rdy) begin
      res_stb <= 0;
    end
  end

 endmodule
