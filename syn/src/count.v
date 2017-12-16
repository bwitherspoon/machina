module count #(
  parameter CNT = 2
)(
  input  clk,
  input  rst,
  input  rdy,
  output stb,
  output [$clog2(CNT)-1:0] dat
);
  reg  [$clog2(CNT)-1:0] cnt = 0;
  wire [$clog2(CNT)-1:0] inc = cnt + 1;

  always @(posedge clk) begin
    if (rst) begin
      cnt <= 0;
    end else if (rdy) begin
      cnt <= inc == CNT ? 0 : inc;
    end
  end

  assign stb = 1;
  assign dat = cnt;

endmodule
