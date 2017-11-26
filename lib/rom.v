module rom #(
  parameter WIDTH = 8,
  parameter DEPTH = 4096,
  parameter FILENAME = ""
)(
  input clk,
  input rst,
  input en,
  input [$clog2(DEPTH)-1:0] addr,
  output reg [WIDTH-1:0] data
);
  reg [WIDTH-1:0] mem [0:DEPTH-1];

  initial if (FILENAME) $readmemh(FILENAME, mem, 0, DEPTH-1);

  always @(posedge clk)
    if (en)
      if (rst)
        data <= 0;
      else
        data <= mem[addr];

endmodule
