module reorder #(
  parameter [31:0] W = 8,
  parameter [31:0] N = 2
)(
  input clk,
  input rst,

  input [N-1:0] s_stb,
  input [N*W-1:0] s_dat,
  output [N-1:0] s_rdy,

  input m_rdy,
  output m_stb,
  output [$clog2(N)+W-1:0] m_dat
);
  localparam [$clog2(N)-1:0] END = N - 1;

  wire mux_adr_rdy;
  wire mux_dat_rdy;
  wire mux_rdy = mux_adr_rdy & mux_dat_rdy;
  wire mux_stb;
  wire [W-1:0] mux_dat;
  wire [$clog2(N)-1:0] mux_adr;

  wire adr_stb = mask == 0;
  wire adr_rdy;
  wire [W-1:0] dat_dat;
  reg [$clog2(N)-1:0] adr_dat [1:0];

  reg [N-1:0] mask = {N{1'b1}};

  initial adr_dat[0] = 0;

  multiplex #(W, N) mux (
    .s_stb(s_stb & mask),
    .s_dat(s_dat),
    .s_rdy(s_rdy),
    .m_rdy(mux_rdy),
    .m_stb(mux_stb),
    .m_dat({mux_adr, mux_dat})
  );

  always @(posedge clk) begin
    if (rst) begin
      mask <= {N{1'b1}};
    end else if (mask == 0) begin
      if (adr_dat[0] == END)
        mask <= {N{1'b1}};
    end else if (mux_stb & mux_rdy) begin
      mask <= mask & ~s_rdy;
    end
  end

  memory #(W, N) mem (
    .clk(clk),
    .rst(rst),
    .s_wa_stb(mux_stb),
    .s_wa_dat(mux_adr),
    .s_wa_rdy(mux_adr_rdy),
    .s_wd_stb(mux_stb),
    .s_wd_dat(mux_dat),
    .s_wd_rdy(mux_dat_rdy),
    .s_ra_stb(adr_stb),
    .s_ra_dat(adr_dat[0]),
    .s_ra_rdy(adr_rdy),
    .m_rd_rdy(m_rdy),
    .m_rd_stb(m_stb),
    .m_rd_dat(dat_dat)
  );

  always @(posedge clk) begin
    if (rst) begin
      adr_dat[0] <= 0;
    end else if (adr_stb & adr_rdy) begin
      adr_dat[1] <= adr_dat[0];
      if (adr_dat[0] == END)
        adr_dat[0] <= 0;
      else
        adr_dat[0] <= adr_dat[0] + 1;
    end
  end

  assign m_dat = {adr_dat[1], dat_dat};

endmodule
