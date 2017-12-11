module top;
  timeunit 1ns;
  timeprecision 1ps;

  `include "debug.vh"
  `include "util.svh"
  `include "reset.svh"
  `include "clock.svh"
  `include "serial.svh"
  `include "interface.svh"

  transmit #(BAUDRATE, FREQUENCY) uut (
    .*,
    .stb(inf_xmt_stb),
    .dat(inf_xmt_dat),
    .rdy(inf_xmt_rdy),
    .txd(ser_txd)
  );

  task test;
    logic [7:0] xmtd;
    logic [7:0] rcvd;
    begin
      for (int i = 0; i < 2; i++) begin
        xmtd = random(255);
        inf_xmt(xmtd);
        ser_rcv(rcvd);
        `ASSERT_EQUAL(rcvd, xmtd);
      end
    end
  endtask : test

  initial begin
    dump;
    seed;
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
