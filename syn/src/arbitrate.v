module arbitrate #(
  parameter [31:0] W = 16,
  parameter [31:0] N = 2
)(
  input clk,
  input rst,

  input [N-1:0] s_stb,
  input [N*W-1:0] s_dat,
  output [N-1:0] s_rdy,

  input n_rdy,
  output n_stb,
  output [$clog2(N)-1:0] n_dat,

  input m_rdy,
  output m_stb,
  output [W-1:0] m_dat
);
  reg [N-1:0] mask = 0;

  always @(posedge clk)
    if (rst)
      mask <= 0;
    else if (m_stb & m_rdy)
      mask <= mask | s_rdy;

  multiplex #(W, N) mux (
    .s_stb(s_stb & ~mask),
    .s_dat(s_dat),
    .s_rdy(s_rdy),
    .n_rdy(n_rdy),
    .n_stb(n_stb),
    .n_dat(n_dat),
    .m_rdy(m_rdy),
    .m_stb(m_stb),
    .m_dat(m_dat)
  );

endmodule
