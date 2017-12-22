module accumulate #(
  parameter [31:0] W = 16
)(
  input clk,
  input rst,

  input s_stb,
  input [W-1:0] s_dat,
  output s_rdy,

  input m_rdy,
  output reg m_stb,
  output reg [W-1:0] m_dat
);
  localparam signed [W:0] MAX = 2**(W-1);
  localparam signed [W:0] MIN = -MAX;

  reg ack = 0;

  wire clr = ack & ~s_stb;

  reg signed [W:0] acc = 0;

  wire signed [W:0] sum = acc + $signed({s_dat[W-1], s_dat});

  initial m_stb = 0;

  assign s_rdy = ~m_stb | m_rdy;

  always @(posedge clk) begin
    if (rst)
      ack <= 0;
    else
      ack <= s_stb & s_rdy;
  end

  always @(posedge clk) begin
    if (rst | clr) begin
      acc <= 0;
    end else if (s_stb & s_rdy) begin
      case ({MIN < sum, sum < MAX})
      2'b11: acc <= sum;
      2'b10: acc <= MAX - 1;
      2'b01: acc <= MIN;
      2'b00: acc <= {(W+1){1'bx}};
      endcase
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      m_stb <= 0;
    end else if (~m_stb) begin
      if (clr) begin
        m_stb <= 1;
        m_dat <= acc;
      end
    end else if (m_rdy) begin
      m_stb <= 0;
    end
  end

 endmodule
