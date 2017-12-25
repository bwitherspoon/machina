
module forward #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  input clk,
  input rst,
  // Input connection slaves
  input  [N-1:0]   s_i_stb,
  input  [N*W-1:0] s_i_dat,
  output [N-1:0]   s_i_rdy,
  // Memory data slave
  input            s_d_stb,
  input  [2*W-1:0] s_d_dat,
  output           s_d_rdy,
  // Output connection masters
  input  [N-1:0]     m_o_rdy,
  output [N-1:0]     m_o_stb,
  output [N*2*W-1:0] m_o_dat,
  // Memory address masters
  input                    m_a_rdy,
  output                   m_a_stb,
  output [$clog2(N+1)-1:0] m_a_dat
);
  wire ord_stb;
  wire ord_rdy;
  wire [$clog2(N+1)+W-1:0] ord_dat;

  wire sep_stb;
  wire sep_rdy;
  wire [W-1:0] sep_dat;

  wire cmb_stb;
  wire cmb_rdy;
  wire [4*W-1:0] cmb_dat;

  wire mul_stb;
  wire mul_rdy;
  wire [4*W-1:0] mul_dat;

  wire acc_stb;
  wire acc_rdy;
  wire [3*W-1:0] acc_dat;

  wire [W-$clog2(N+1):0] nc;
  wire unused = &{1'b0,
    nc,
    sep_dat[W-1:$clog2(N+1)],
    mul_dat[0+:W],
    acc_dat[2*W+:W],
  1'b0};

  reorder #(W, N+1) ord (
    .clk(clk),
    .rst(rst),
    .s_stb({1'b1, s_i_stb}),
    .s_dat({{W{1'b1}}, s_i_dat}),
    .s_rdy({nc[0], s_i_rdy}),
    .m_rdy(ord_rdy),
    .m_stb(ord_stb),
    .m_dat(ord_dat)
  );

  seperate #(W) sep (
    .s_stb(ord_stb),
    .s_dat({{(W-$clog2(N+1)){1'bx}}, ord_dat}),
    .s_rdy(ord_rdy),
    .m_rdy({m_a_rdy, sep_rdy}),
    .m_stb({m_a_stb, sep_stb}),
    .m_dat({nc[1+:W-$clog2(N+1)], m_a_dat, sep_dat})
  );


  combine #(2*W) cmb (
    .s_stb({s_d_stb, sep_stb}),
    .s_dat({s_d_dat, {W{1'b0}}, sep_dat}),
    .s_rdy({s_d_rdy, sep_rdy}),
    .m_rdy(cmb_rdy),
    .m_stb(cmb_stb),
    .m_dat(cmb_dat)
  );

  multiply #(2*W) mul (
    .clk(clk),
    .rst(rst),
    .s_stb(cmb_stb),
    .s_dat(cmb_dat),
    .s_rdy(cmb_rdy),
    .m_rdy(mul_rdy),
    .m_stb(mul_stb),
    .m_dat(mul_dat)
  );

  accumulate #(3*W, 2**(W-1)) acc (
    .clk(clk),
    .rst(rst),
    .s_stb(mul_stb),
    .s_dat(mul_dat[W+:3*W]),
    .s_rdy(mul_rdy),
    .m_rdy(acc_rdy),
    .m_stb(acc_stb),
    .m_dat(acc_dat)
  );

  distribute #(2*W, N) dis (
    .clk(clk),
    .rst(rst),
    .s_stb(acc_stb),
    .s_dat(acc_dat[0+:2*W]),
    .s_rdy(acc_rdy),
    .m_rdy(m_o_rdy),
    .m_stb(m_o_stb),
    .m_dat(m_o_dat)
  );

endmodule
