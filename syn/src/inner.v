module inner #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 4,
  parameter [31:0] R = 2
)(
  input clk,
  input rst,
  // Slaves
  input  [N:0] s_stb,
  input  [(N+1)*W-1:0] s_dat,
  output [N:0] s_rdy,
  // Masters
  input  [1:0] m_rdy,
  output [1:0] m_stb,
  output [4*W-1:0] m_dat
);

  wire [N:0] arg_stb = {1'b1, s_stb[N-1:0]};
  wire [N:0] arg_rdy;
  wire [(N+1)*W-1:0] arg_dat = {{W{1'b1}}, s_dat[N*W-1:0]};

  wire mux_stb;
  wire mux_rdy;
  wire [$clog2(N+1)+W-1:0] mux_dat;

  wire [1:0] sep_stb;
  wire [1:0] sep_rdy;
  wire [W-1:0] sep_adr;
  wire [W-1:0] sep_dat;

  wire wts_stb;
  wire wts_rdy;
  wire [2*W-1:0] wts_dat;

  wire cmb_stb;
  wire cmb_rdy;
  wire [4*W-1:0] cmb_dat;

  wire mul_stb;
  wire mul_rdy;
  wire [4*W-1:0] mul_dat;

  wire acc_stb;
  wire acc_rdy = m_rdy[0];
  wire [3*W-1:0] acc_dat;

  assign s_rdy = {1'b0, arg_rdy[N-1:0]};

  assign m_stb[0] = acc_stb;
  assign m_stb[1] = 1'b0;
  assign m_dat[0+:2*W] = acc_dat[0+:2*W];
  assign m_dat[2*W+:2*W] = {(2*W){1'bx}};

  wire nc = &{1'b0,
    arg_rdy[N],
    sep_dat[W-1:$clog2(N+1)],
    mul_dat[0+:W],
    acc_dat[2*W+:W],
  1'b0};

  reorder #(W, N+1) mux (
    .clk(clk),
    .rst(rst),
    .s_stb(arg_stb),
    .s_dat(arg_dat),
    .s_rdy(arg_rdy),
    .m_rdy(mux_rdy),
    .m_stb(mux_stb),
    .m_dat(mux_dat)
  );

  seperate #(W, 2) sep (
    .s_stb(mux_stb),
    .s_dat({{(W-$clog2(N+1)){1'b0}}, mux_dat}),
    .s_rdy(mux_rdy),
    .m_rdy(sep_rdy),
    .m_stb(sep_stb),
    .m_dat({sep_adr, sep_dat})
  );

  memory #(2*W, N+1) wts (
    .clk(clk),
    .rst(rst),
    .waddr_stb(/* TODO */ 1'b0),
    .waddr_dat(/* TODO */ {$clog2(N+1){1'b0}}),
    .waddr_rdy(/* TODO */),
    .wdata_stb(/* TODO */ 1'b0),
    .wdata_dat(/* TODO */ {(2*W){1'b0}}),
    .wdata_rdy(/* TODO */),
    .raddr_stb(sep_stb[0]),
    .raddr_dat(sep_adr[$clog2(N+1)-1:0]),
    .raddr_rdy(sep_rdy[0]),
    .rdata_rdy(wts_rdy),
    .rdata_stb(wts_stb),
    .rdata_dat(wts_dat)
  );

  combine #(2*W, 2) cmb (
    .s_stb({wts_stb, sep_stb[1]}),
    .s_dat({wts_dat, {W{1'b0}}, sep_dat}),
    .s_rdy({wts_rdy, sep_rdy[1]}),
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

endmodule
