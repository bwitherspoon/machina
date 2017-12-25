module distribute #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  input clk,
  input rst,
  // Slave
  input s_stb,
  input [W-1:0] s_dat,
  output s_rdy,
  // Masters
  input [N-1:0] m_rdy,
  output [N-1:0] m_stb,
  output [N*W-1:0] m_dat
);
  reg [N-1:0] ack = 0;

  always @ (posedge clk)
    if (rst | &ack)
      ack <= 0;
    else
      ack <= ack | (m_stb & m_rdy);

  assign s_rdy = &ack;
  assign m_stb = {N{s_stb}} & ~ack;
  assign m_dat = {N{s_dat}};

endmodule
