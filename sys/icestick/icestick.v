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
  localparam BITS = 8;

  wire rcv_err;
  wire rcv_stb;
  wire rcv_rdy;
  wire [7:0] rcv_dat;

  wire sel_stb;
  wire sel_rdy;
  wire sel_dat;

  wire [1:0] dux_stb;
  wire [15:0] dux_dat;

  wire [1:0] mul_rdy;
  wire mul_stb;
  wire [15:0] mul_dat;

  wire upk_stb;
  wire upk_rdy;
  wire [7:0] upk_dat;

  wire xmt_rdy;

  receive #(BAUD, FREQ) rcv (
    .clk(clk),
    .rst(1'b0),
    .rxd(rs232_rxd),
    .rdy(rcv_rdy),
    .stb(rcv_stb),
    .dat(rcv_dat),
    .err(rcv_err)
  );

  count #(2) sel (
    .clk(clk),
    .rst(1'b0),
    .rdy(sel_rdy),
    .stb(sel_stb),
    .dat(sel_dat)
  );

  demultiplex #(.ARGW(8), .OUTC(2)) dux (
    .clk(clk),
    .rst(1'b0),
    .arg_stb(rcv_stb),
    .arg_dat(rcv_dat),
    .arg_rdy(rcv_rdy),
    .sel_stb(sel_stb),
    .sel_dat(sel_dat),
    .sel_rdy(sel_rdy),
    .out_stb(dux_stb),
    .out_dat(dux_dat),
    .out_rdy(mul_rdy)
  );

  multiply #(.ARGW(8)) mul (
    .clk(clk),
    .rst(1'b0),
    .arg_stb(dux_stb),
    .arg_dat(dux_dat),
    .arg_rdy(mul_rdy),
    .res_stb(mul_stb),
    .res_dat(mul_dat),
    .res_rdy(upk_rdy)
  );

  unpack #(.ARGW(8), .ARGD(2)) upk (
    .clk(clk),
    .rst(1'b0),
    .arg_stb(mul_stb),
    .arg_dat(mul_dat),
    .arg_rdy(upk_rdy),
    .out_stb(upk_stb),
    .out_dat(upk_dat),
    .out_rdy(xmt_rdy)
  );

  transmit #(BAUD, FREQ) xmt (
    .clk(clk),
    .rst(1'b0),
    .stb(upk_stb),
    .dat(upk_dat),
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
