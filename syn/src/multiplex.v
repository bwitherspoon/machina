module multiplex #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  // Slaves
  input [N-1:0] s_stb,
  input [N*W-1:0] s_dat,
  output reg [N-1:0] s_rdy,
  // Master
  input m_rdy,
  output m_stb,
  output [$clog2(N)+W-1:0] m_dat
);
  // Priority encoder
  reg [$clog2(N)-1:0] i, n;
  always @* begin
    n = {$clog2(N){1'b0}};
    for (i = N - 1; i > 0; i = i - 1)
      if (s_stb[i])
        n = i;
  end
  // Decoder
  always @* begin
    s_rdy = {N{1'b0}};
    s_rdy[n] = s_stb[n] & m_rdy;
  end
  // Multiplexer
  assign m_stb = |s_stb;
  assign m_dat = {n, s_dat[n*W+:W]};

endmodule
