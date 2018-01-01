module multiply #(
  parameter W = 8,
  parameter Q = 0
)(
  input clk,
  input rst,

  input [1:0] s_stb,
  input [2*W-1:0] s_dat,
  output [1:0] s_rdy,

  input m_rdy,
  output reg m_stb,
  output reg [2*W-1:0] m_dat
);
  initial m_stb = 0;

  always @(posedge clk) begin
    if (rst) begin
      m_stb <= 0;
    end else if (&s_stb & (~m_stb | m_rdy)) begin
      m_stb <= 1;
      m_dat <= $signed(s_dat[0+:W]) * $signed(s_dat[W+:W]) >>> Q;
    end else if (m_stb & m_rdy) begin
      m_stb <= 0;
    end
  end

  assign s_rdy = {2{&s_stb & (~m_stb | m_rdy)}};

endmodule
