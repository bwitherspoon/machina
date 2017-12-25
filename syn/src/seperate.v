module seperate #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  // Slave
  input s_stb,
  input [N*W-1:0] s_dat,
  output s_rdy,
  // Masters
  input [N-1:0] m_rdy,
  output [N-1:0] m_stb,
  output [N*W-1:0] m_dat
);
  assign s_rdy = &m_rdy;
  assign m_stb = s_stb;
  assign m_dat = s_dat;

endmodule
