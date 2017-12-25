module memory #(
  parameter WIDTH = 16,
  parameter DEPTH = 256,
  parameter INIT = ""
)(
  input clk,
  input rst,
  // Write address slave
  input s_wa_stb,
  input [$clog2(DEPTH)-1:0] s_wa_dat,
  output s_wa_rdy,
  // Write data slave
  input s_wd_stb,
  input [WIDTH-1:0] s_wd_dat,
  output s_wd_rdy,
  // Read address slave
  input s_ra_stb,
  input [$clog2(DEPTH)-1:0] s_ra_dat,
  output s_ra_rdy,
  // Read data master
  input m_rd_rdy,
  output reg m_rd_stb,
  output reg [WIDTH-1:0] m_rd_dat
);
  reg [WIDTH-1:0] mem [0:DEPTH-1];

  if (INIT != "") initial $readmemh(INIT, mem, 0, DEPTH-1);

  initial m_rd_stb = 0;

  assign s_wa_rdy = s_wa_stb & s_wd_stb & ~(s_ra_stb & s_ra_dat == s_wa_dat);
  assign s_wd_rdy = s_wa_rdy;
  assign s_ra_rdy = ~m_rd_stb | m_rd_rdy;

  always @(posedge clk) begin
    if (rst) begin
      m_rd_stb <= 0;
    end else if (s_ra_stb & s_ra_rdy) begin
      m_rd_stb <= 1;
      m_rd_dat <= mem[s_ra_dat];
    end else if (m_rd_stb & m_rd_rdy) begin
      m_rd_stb <= 0;
    end
  end

  always @(posedge clk) begin
    if (s_wa_stb & s_wd_stb) begin
      mem[s_wa_dat] <= s_wd_dat;
    end
  end

endmodule
