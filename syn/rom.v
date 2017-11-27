module rom #(
  parameter WIDTH = 8,
  parameter DEPTH = 4096,
  parameter FILENAME = "rom.dat"
)(
  input clk,
  input rst,
  input en,
  input [$clog2(DEPTH)-1:0] adr,
  output reg [WIDTH-1:0] dat
);
  reg [WIDTH-1:0] mem [0:DEPTH-1];

  initial $readmemh(FILENAME, mem, 0, DEPTH-1);

  always @(posedge clk)
    if (en)
      if (rst)
        dat <= 0;
      else
        dat <= mem[adr];

endmodule
