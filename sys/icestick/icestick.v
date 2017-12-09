module icestick (
  /* Discera 12 MHz oscilator */
  input  clk,
  /* FTDI FT2232H USB */
  input  rs232_rxd,
  // input  rs232_rts,
  // input  rs232_dtr,
  output rs232_txd,
  // output rs232_cts,
  // output rs232_dcd,
  // output rs232_dsr,
  /* Vishay TFDU4101 IrDA */
  // input  irda_rxd,
  // output irda_txd,
  // output irda_sd,
  /* LEDs */
  output [4:0] led,
  /* Diligent Pmod connector (2 x 6) */
  // inout [7:0] pmod,
  /* Expansion I/O (3.3 V) */
  // inout [15:0] gpio
);
  localparam FREQ = 12000000;
  localparam BAUD = 9600;

  wire stb;
  wire rdy;
  wire [7:0] dat;

  receive #(BAUD, FREQ) rcv (
    .clk(clk),
    .rst(1'b0),
    .rxd(rs232_rxd),
    .rdy(rdy),
    .stb(stb),
    .dat(dat)
  );

  transmit #(FREQ, BAUD) xmt (
    .clk(clk),
    .rst(1'b0),
    .stb(stb),
    .dat(dat),
    .rdy(rdy),
    .txd(rs232_txd)
  );

  assign led = 5'b10000;

  wire nc = &{1'b0,
              1'b0};
endmodule
