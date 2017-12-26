module seperate #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  input clk,
  input rst,
  // Slave
  input s_stb,
  input [N*W-1:0] s_dat,
  output s_rdy,
  // Masters
  input [N-1:0] m_rdy,
  output [N-1:0] m_stb,
  output [N*W-1:0] m_dat
);
  reg [N-1:0] m_ack = 0;
  always @(posedge clk) begin
    if (rst) begin
      m_ack <= 0;
    end else if (&m_ack) begin
      if (s_stb & s_rdy)
        m_ack <= 0;
    end else if (m_stb & m_rdy) begin
      m_ack <= m_ack | m_rdy;
    end
  end

  assign s_rdy = &m_ack;
  assign m_stb = {N{s_stb}} & ~m_ack;
  assign m_dat = s_dat;

endmodule
