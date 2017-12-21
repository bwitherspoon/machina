module unpack #(
  parameter [31:0] W = 8,
  parameter [31:0] D = 2
)(
  input clk,
  input rst,

  input s_stb,
  input [W*D-1:0] s_dat,
  output s_rdy,

  input m_rdy,
  output reg m_stb,
  output reg [W-1:0] m_dat
);
  localparam [$clog2(D)-1:0] END = D - 1;

  reg [$clog2(D)-1:0] idx = 0;

  initial m_stb = 0;

  assign s_rdy = idx == END & m_rdy;

  always @(posedge clk) begin
    if (rst) begin
      idx <= 0;
    end else if (idx == 0) begin
      if (s_stb)
        idx <= idx + 1;
    end else if (m_stb & m_rdy) begin
      if (idx == END)
        idx <= 0;
      else
        idx <= idx + 1;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      m_stb <= 0;
    end else if (idx == 0) begin
      if (s_stb)
        m_stb <= 1;
      else if (m_stb & m_rdy)
        m_stb <= 0;
    end
  end

  always @(posedge clk) begin
    if ((idx == 0 & s_stb) | (idx != 0 & m_stb & m_rdy))
      m_dat <= s_dat[W*idx+:W];
  end

endmodule
