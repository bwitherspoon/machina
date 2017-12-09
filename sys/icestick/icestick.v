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

  wire rcv_stb;
  wire [7:0] rcv_dat;

  receive #(BAUD, FREQ) rcv (
    .clk(clk),
    .rst(1'b0),
    .rxd(rs232_rxd),
    .rdy(1'b0),
    .stb(rcv_stb),
    .dat(rcv_dat)
  );

  assign rs232_txd = rs232_rxd;

  assign led = 5'b10000;

  wire nc = &{1'b0,
              rcv_stb,
              rcv_dat,
              1'b0};
endmodule
