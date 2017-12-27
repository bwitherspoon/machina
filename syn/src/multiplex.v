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
  // Priority encode
  reg [$clog2(N)-1:0] s_adr, n;
  always @* begin : encode
    s_adr = {$clog2(N){1'b0}};
    for (n = N - 1; n > 0; n = n - 1)
      if (s_stb[n])
        s_adr = n;
  end
  // Decode
  always @* begin : decode
    s_rdy = {N{1'b0}};
    s_rdy[s_adr] = s_stb[s_adr] & m_rdy;
  end
  // Multiplex
  assign m_stb = |s_stb;
  assign m_dat = {s_adr, s_dat[s_adr*W+:W]};

endmodule
