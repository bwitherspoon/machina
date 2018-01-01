module demultiplex #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  // Select slave
  input n_stb,
  input [$clog2(N)-1:0] n_dat,
  output n_rdy,
  // Input slave
  input s_stb,
  input [W-1:0] s_dat,
  output s_rdy,
  // Output masters
  input [N-1:0] m_rdy,
  output reg [N-1:0] m_stb,
  output reg [N*W-1:0] m_dat
);
  always @* begin
    m_stb = {N{1'b0}};
    m_dat = {N{1'bx}};
    if (n_stb) begin
      m_stb[n_dat] = s_stb;
      m_dat[n_dat*W+:W] = s_dat[W-1:0];
    end
  end

  assign n_rdy = n_stb ? m_rdy[n_dat] : 1'b0;
  assign s_rdy = n_rdy;

endmodule
