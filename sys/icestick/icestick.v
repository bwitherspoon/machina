module icestick (
  /* Discera 12 MHz oscilator */
  input  clk,
  /* FTDI FT2232H USB */
  // input  rs232_rxd,
  // input  rs232_rts,
  // input  rs232_dtr,
  // output rs232_txd,
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

  assign led = 5'b01111;

endmodule
