module top;
  timeunit 1ns;
  timeprecision 1ps;

  `include "debug.vh"
  `include "util.svh"
  `include "reset.svh"
  `include "clock.svh"
  `include "serial.svh"

  logic rxd;
  logic txd;
  logic rdy;
  logic stb;
  logic err;
  logic [7:0] dat;

  assign ser_txd = txd;
  assign rxd = ser_rxd;

  receive  #(BAUDRATE, FREQUENCY) rx (.*);
  transmit #(BAUDRATE, FREQUENCY) tx (.*);

  task test;
    logic [7:0] xmtd;
    logic [7:0] rcvd;
    repeat (8) begin
      xmtd = random(255);
      fork
        ser_xmt(xmtd);
        ser_rcv(rcvd);
      join
      `ASSERT_EQUAL(err, 0);
      `ASSERT_EQUAL(rcvd, xmtd);
    end
  endtask

  initial begin
    dump;
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
