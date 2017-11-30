module memory #(
  parameter WIDTH = 8,
  parameter DEPTH = 4096,
  parameter DATA = "/dev/null"
)(
  input clk,
  input rst,
  input en,
  input [$clog2(DEPTH)-1:0] adr,
  output reg [WIDTH-1:0] dat
);
  reg [WIDTH-1:0] mem [0:DEPTH-1];

  initial $readmemh(DATA, mem, 0, DEPTH-1);

  always @(posedge clk)
    if (en)
      if (rst)
        dat <= 0;
      else
        dat <= mem[adr];

endmodule
