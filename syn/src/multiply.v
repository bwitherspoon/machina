module multiply #(
  parameter W = 8
)(
  input clk,
  input rst,

  input s_stb,
  input [2*W-1:0] s_dat,
  output s_rdy,

  input m_rdy,
  output reg m_stb,
  output reg [2*W-1:0] m_dat
);
  wire s_ack = s_stb & s_rdy;
  wire m_ack = m_stb & m_rdy;

  reg stb = 0;
  reg signed [W-1:0] arg [1:0];

  assign s_rdy = ~m_stb | m_rdy;

  initial m_stb = 0;

  always @(posedge clk) begin
    if (s_ack) begin
      arg[0] <= s_dat[0+:W];
      arg[1] <= s_dat[W+:W];
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      stb <= 0;
    end else if (stb) begin
      stb <= s_stb | ~s_rdy;
    end else begin
      stb <= s_stb & s_rdy;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      m_stb <= 0;
    end else if (stb) begin
      if (~m_stb | m_rdy) begin
        m_stb <= 1;
        m_dat <= arg[0] * arg[1];
      end
    end else if (m_stb & m_rdy) begin
      m_stb <= 0;
    end
  end

endmodule
