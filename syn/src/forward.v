
module forward #(
  parameter [31:0] W = 16,
  parameter [31:0] N = 2,
  parameter [31:0] Q = 8
)(
  input clk,
  input rst,
  // Input connection slaves
  input [N-1:0] s_stb,
  input [N*W-1:0] s_dat,
  output [N-1:0] s_rdy,
  // Output connection master
  input m_rdy,
  output m_stb,
  output [W-1:0] m_dat,
  // Memory data slave
  input d_stb,
  input [W-1:0] d_dat,
  output d_rdy,
  // Memory address master
  input a_rdy,
  output a_stb,
  output [$clog2(N)-1:0] a_dat
);
  wire mux_stb;
  wire mux_rdy;
  wire [W-1:0] mux_dat;

  wire mul_stb;
  wire mul_rdy;
  wire [2*W-1:0] mul_dat;

  wire acc_stb;
  wire acc_rdy;
  wire [2*W-1:0] acc_dat;

  wire [2*W-1:0] sat_dat;

  wire unused = &{1'b0,
                  sat_dat[W+:W],
                  1'b0};

  multiplex #(W, N) mux (
    .s_stb(s_stb),
    .s_dat(s_dat),
    .s_rdy(s_rdy),
    .n_rdy(a_rdy),
    .n_stb(a_stb),
    .n_dat(a_dat),
    .m_rdy(mux_rdy),
    .m_stb(mux_stb),
    .m_dat(mux_dat)
  );

  multiply #(W, Q) mul (
    .clk(clk),
    .rst(rst),
    .s_stb({d_stb, mux_stb}),
    .s_dat({d_dat, mux_dat}),
    .s_rdy({d_rdy, mux_rdy}),
    .m_rdy(mul_rdy),
    .m_stb(mul_stb),
    .m_dat(mul_dat)
  );

  accumulate #(2*W) acc (
    .clk(clk),
    .rst(rst),
    .s_stb(mul_stb),
    .s_dat(mul_dat),
    .s_rdy(mul_rdy),
    .m_rdy(acc_rdy),
    .m_stb(acc_stb),
    .m_dat(acc_dat)
  );

  saturate #(2*W, W) sat (acc_dat, sat_dat);

  decimate #(W, N+1) dec (
    .clk(clk),
    .rst(rst),
    .s_stb(acc_stb),
    .s_dat(sat_dat[0+:W]),
    .s_rdy(acc_rdy),
    .m_rdy(m_rdy),
    .m_stb(m_stb),
    .m_dat(m_dat)
  );

endmodule
