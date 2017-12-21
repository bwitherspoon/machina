module combine #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  // Slaves
  input [N-1:0] s_stb,
  input [N*W-1:0] s_dat,
  output [N-1:0] s_rdy,
  // Master
  input m_rdy,
  output m_stb,
  output [N*W-1:0] m_dat
);
  assign s_rdy = {N{m_stb & m_rdy}};
  assign m_stb = &s_stb;
  assign m_dat = s_dat;

endmodule
