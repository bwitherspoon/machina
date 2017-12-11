module top;
  timeunit 1ns;
  timeprecision 1ps;

  `include "debug.vh"
  `include "util.svh"
  `include "reset.svh"
  `include "clock.svh"
  `include "serial.svh"
  `include "interface.svh"

  wire rxd = ser_rxd;
  wire rdy = inf_rcv_rdy;
  wire stb;
  wire [7:0] dat;
  wire err;

  assign inf_rcv_stb = stb;
  assign inf_rcv_dat = dat;

  receive #(BAUDRATE, FREQUENCY) uut (.*);

  task test0;
    logic [7:0] xmtd;
    logic [7:0] rcvd;
    repeat (8) begin
      xmtd = random(255);
      fork
        ser_xmt(xmtd);
        inf_rcv(rcvd);
      join
      `ASSERT_EQUAL(xmtd, rcvd);
    end
  endtask

  task test1;
    logic [7:0] xmtd;
    logic [7:0] rcvd;
    repeat (8) begin
      xmtd = random(255);
      ser_xmt(xmtd);
      inf_rcv(rcvd);
      `ASSERT_EQUAL(xmtd, rcvd);
    end
  endtask

  task test2;
    logic [7:0] xmtd [2];
    logic [7:0] rcvd;
    repeat (8) begin
      xmtd[0] = random(255);
      ser_xmt(xmtd[0]);
      `ASSERT_EQUAL(err, 0);
      xmtd[1] = random(255);
      fork
        ser_xmt(xmtd[1]);
        #(9.5*CYCLES*PERIOD) inf_rcv(rcvd);
      join
      `ASSERT_EQUAL(err, 0);
      `ASSERT_EQUAL(rcvd, xmtd[0]);
      inf_rcv(rcvd);
      `ASSERT_EQUAL(rcvd, xmtd[1]);
    end
  endtask

  task test;
    //test0;
    //test1;
    //test2;
  endtask

  initial begin
    dump;
    seed;
    #PERIOD;
    test;
    //reset;
    //test;
    $finish;
  end

endmodule
