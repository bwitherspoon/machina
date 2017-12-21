module icestick (
  /* Discera 12 MHz oscilator */
  input  clk,
  /* FTDI FT2232H USB */
  input  rs232_rxd,
  input  rs232_rts,
  input  rs232_dtr,
  output rs232_txd,
  output rs232_cts,
  output rs232_dcd,
  output rs232_dsr,
  /* Vishay TFDU4101 IrDA */
  input  irda_rxd,
  output irda_txd,
  output irda_sd,
  /* LEDs */
  output [4:0] led,
  /* Diligent Pmod connector (2 x 6) */
  inout [7:0] pmod,
  /* Expansion I/O (3.3 V) */
  inout [15:0] gpio
);
  localparam FREQ = 12000000;
  localparam BAUD = 9600;

  wire rcv_err;
  wire rcv_rdy;
  wire rcv_stb;
  wire [7:0] rcv_dat;

  wire rpk_rdy;
  wire rpk_stb;
  wire [15:0] rpk_dat;

  wire mul_rdy;
  wire mul_stb;
  wire [15:0] mul_dat;

  wire xmt_rdy;
  wire xmt_stb;
  wire [7:0] xmt_dat;

  receive #(BAUD, FREQ) rcv (
    .clk(clk),
    .rst(1'b0),
    .rxd(rs232_rxd),
    .rdy(rcv_rdy),
    .stb(rcv_stb),
    .dat(rcv_dat),
    .err(rcv_err)
  );

  repack #(.W(8), .D(2)) rpk (
    .clk(clk),
    .rst(1'b0),
    .s_stb(rcv_stb),
    .s_dat(rcv_dat),
    .s_rdy(rcv_rdy),
    .m_rdy(rpk_rdy),
    .m_stb(rpk_stb),
    .m_dat(rpk_dat)
  );

  multiply #(.W(8)) mul (
    .clk(clk),
    .rst(1'b0),
    .s_stb(rpk_stb),
    .s_dat(rpk_dat),
    .s_rdy(rpk_rdy),
    .m_stb(mul_stb),
    .m_dat(mul_dat),
    .m_rdy(mul_rdy)
  );

  unpack #(.W(8), .D(2)) upk (
    .clk(clk),
    .rst(1'b0),
    .s_stb(mul_stb),
    .s_dat(mul_dat),
    .s_rdy(mul_rdy),
    .m_rdy(xmt_rdy),
    .m_stb(xmt_stb),
    .m_dat(xmt_dat)
  );

  transmit #(BAUD, FREQ) xmt (
    .clk(clk),
    .rst(1'b0),
    .stb(xmt_stb),
    .dat(xmt_dat),
    .rdy(xmt_rdy),
    .txd(rs232_txd)
  );

  assign led = {~rcv_err, {4{rcv_err}}};

  assign rs232_cts = 0;
  assign rs232_dcd = 0;
  assign rs232_dsr = 0;

  assign irda_txd = 0;
  assign irda_sd = 1;

  wire nc = &{1'b0,
              rs232_rts,
              rs232_dtr,
              irda_rxd,
              pmod,
              gpio,
              1'b0};
endmodule
