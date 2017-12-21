module demultiplex #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  // Slave
  input s_stb,
  input [$clog2(N)+W-1:0] s_dat,
  output s_rdy,
  // Masters
  input [N-1:0] m_rdy,
  output reg [N-1:0] m_stb,
  output reg [N*W-1:0] m_dat
);
  wire [$clog2(N)-1:0] sel = s_dat[W+:$clog2(N)];

  always @* begin
    m_stb = {N{1'b0}};
    m_dat = {N{1'bx}};
    if (s_stb) begin
      m_stb[sel] = 1'b1;
      m_dat[sel*W+:W] = s_dat[W-1:0];
    end
  end

  assign s_rdy = s_stb ? m_rdy[sel] : 1'b0;

endmodule
