module multiply #(
  parameter ARGW = 16
)(
  input clk,
  input rst,

  input [1:0] arg_stb,
  input [2*ARGW-1:0] arg_dat,
  output [1:0] arg_rdy,

  output reg res_stb,
  output reg [2*ARGW-1:0] res_dat,
  input res_rdy
);
  wire [1:0] arg_ack = arg_stb & arg_rdy;
  wire res_ack = res_stb & res_rdy;
  wire res_bsy = res_stb & ~res_rdy;

  reg [1:0] int_stb = 2'b00;
  reg signed [ARGW-1:0] arg [1:0];

  assign arg_rdy = ~int_stb | {2{&int_stb & res_rdy}};

  integer i;
  always @(posedge clk) begin
    for (i = 0; i < 2; i = i + 1) begin
      if (arg_ack[i]) begin
        arg[i] <= arg_dat[ARGW*i+:ARGW];
      end
    end
  end

  integer j;
  always @(posedge clk) begin
    for (j = 0; j < 2; j = j + 1) begin
      if (rst) begin
        int_stb[j] <= 0;
      end else if (~int_stb[j] & arg_ack[j]) begin
        int_stb[j] <= 1;
      end else if (&int_stb & ~res_bsy) begin
        int_stb[j] <= 0;
      end
    end
  end

  initial res_stb = 0;

  always @(posedge clk) begin
    if (rst) begin
      res_stb <= 0;
    end else if (&int_stb) begin
      if (~res_stb) begin
        res_stb <= 1;
        res_dat <= arg[0] * arg[1];
      end
    end else if (res_ack) begin
      res_stb <= 0;
    end
  end

endmodule
