module saturate #(
  parameter [31:0] W = 16,
  parameter [31:0] S = W - 1
)(
  input signed [W-1:0] i,
  output signed [W-1:0] o
);
  localparam signed [W-1:0] MAX = {{(W-S+1){1'b0}}, {(S-1){1'b1}}};
  localparam signed [W-1:0] MIN = ~MAX;
  assign o = MIN < i ? i < MAX ? i : MAX : MIN;
 endmodule
