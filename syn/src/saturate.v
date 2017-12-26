module saturate #(
  parameter [31:0] WIDTH = 16,
  parameter [31:0] LIMIT = WIDTH - 1
)(
  input  signed [WIDTH-1:0] i,
  output signed [WIDTH-1:0] o
);
  localparam signed [WIDTH-1:0] MAX = {{(WIDTH-LIMIT+1){1'b0}}, {(LIMIT-1){1'b1}}};
  localparam signed [WIDTH-1:0] MIN = ~MAX;
  reg signed [WIDTH-1:0] o;
  always @*
    case ({MIN < i, i < MAX})
      2'b11: o = i[WIDTH-1:0];
      2'b10: o = MAX;
      2'b01: o = MIN;
      2'b00: o = {WIDTH{1'bx}};
    endcase
 endmodule
