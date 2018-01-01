module multiplex #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  // Input slaves
  input [N-1:0] s_stb,
  input [N*W-1:0] s_dat,
  output reg [N-1:0] s_rdy,
  // Index master
  input n_rdy,
  output n_stb,
  output reg [$clog2(N)-1:0] n_dat,
  // Output master
  input m_rdy,
  output m_stb,
  output [W-1:0] m_dat
);
  // Priority encode
  reg [$clog2(N)-1:0] n;
  always @* begin : encode
    n_dat = {$clog2(N){1'b0}};
    for (n = N - 1; n > 0; n = n - 1)
      if (s_stb[n])
        n_dat = n;
  end
  // Decode
  always @* begin : decode
    s_rdy = {N{1'b0}};
    s_rdy[n_dat] = n_rdy & m_rdy;
  end
  // Multiplex
  assign n_stb = |s_stb;
  assign m_stb = n_stb;
  assign m_dat = s_dat[n_dat*W+:W];

endmodule
