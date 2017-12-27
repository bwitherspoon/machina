module decimate #(
  parameter [31:0] W = 16,
  parameter [31:0] M = 2
)(
  input clk,
  input rst,
  // Slave
  input s_stb,
  input [W-1:0] s_dat,
  output s_rdy,
  // Master
  input m_rdy,
  output m_stb,
  output [W-1:0] m_dat
);
  localparam [$clog2(M)-1:0] CNT = M - 1;

  reg [$clog2(M)-1:0] cnt = 0;

  always @(posedge clk) begin
    if (rst) begin
      cnt <= 0;
    end else if (cnt == CNT) begin
      if (m_stb & m_rdy)
        cnt <= 0;
    end else if (s_stb & s_rdy) begin
      cnt <= cnt + 1;
    end
  end

  assign s_rdy = ~m_stb | m_rdy;
  assign m_stb = cnt == CNT;
  assign m_dat = s_dat;

endmodule
