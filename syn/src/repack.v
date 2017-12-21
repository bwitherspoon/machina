module repack #(
  parameter [31:0] W = 8,
  parameter [31:0] D = 2
)(
  input clk,
  input rst,

  input s_stb,
  input [W-1:0] s_dat,
  output s_rdy,

  input m_rdy,
  output reg m_stb,
  output reg [W*D-1:0] m_dat
);
  localparam [$clog2(D)-1:0] END = D[$clog2(D)-1:0] - 1;

  reg [$clog2(D)-1:0] idx = 0;

  initial m_stb = 0;

  assign s_rdy = ~m_stb | m_rdy;

  always @(posedge clk) begin
    if (rst) begin
      idx <= 0;
    end else if (idx == END) begin
      if (m_stb & m_rdy)
        idx <= 0;
    end else begin
      if (s_stb & s_rdy)
        idx <= idx + 1;
    end
  end

  always @(posedge clk) begin
    if (rst)
      m_stb <= 0;
    else if (idx == END)
      m_stb <= m_stb & m_rdy ? 0 : 1;
  end

  always @(posedge clk) begin
    if (s_stb & s_rdy)
      m_dat[W*idx+:W] <= s_dat;
  end

endmodule
