module saturate #(
  parameter [31:0] WIDTH = 16,
  parameter signed [WIDTH:0] UPPER = 2**(WIDTH-1),
  parameter signed [WIDTH:0] LOWER = -UPPER
)(
  input signed [WIDTH:0] val,
  output reg [WIDTH-1:0] out
);
  always @*
    case ({LOWER < val, val < UPPER})
      2'b11: out = val[WIDTH-1:0];
      2'b10: out = UPPER - 1;
      2'b01: out = LOWER;
      2'b00: out = {WIDTH{1'bx}};
    endcase

 endmodule
