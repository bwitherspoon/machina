module accumulate #(
  parameter [31:0] W = 16
)(
  input clk,
  input rst,
  // Slave
  input s_stb,
  input [W-1:0] s_dat,
  output s_rdy,
  // Master
  input m_rdy,
  output reg m_stb,
  output reg [W-1:0] m_dat
);
  localparam signed [W-1:0] MAX = {1'b0, {(W-1){1'b1}}};
  localparam signed [W-1:0] MIN = ~MAX;

  wire signed [W:0] sum = $signed({m_dat[W-1], m_dat}) + $signed({s_dat[W-1], s_dat});

  assign s_rdy = ~m_stb | m_rdy;

  initial begin
    m_stb = 0;
    m_dat = 0;
  end

  always @(posedge clk) begin
    if (rst) begin
      m_stb <= 0;
      m_dat <= 0;
    end else if (s_stb & s_rdy) begin
      m_stb <= 1;
      case (sum[W:W-1])
        2'b01: m_dat <= MAX;
        2'b10: m_dat <= MIN;
        default: m_dat <= sum;
      endcase
    end else if (m_stb & m_rdy) begin
      m_stb <= 0;
    end
  end
 endmodule
