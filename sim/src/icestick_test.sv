`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "random.svh"
`include "reset.svh"
`include "serial.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam FREQ = 12000000;
  localparam BAUD = 9600;

  `clock(FREQ)
  `serial(BAUD)

  icestick ice (
    .clk,
    .rs232_rxd(rxd),
    .rs232_rts(1'b0),
    .rs232_dtr(1'b0),
    .rs232_txd(txd),
    .rs232_cts(),
    .rs232_dcd(),
    .rs232_dsr(),
    .irda_rxd(1'b0),
    .irda_txd(),
    .irda_sd(),
    .led(),
    .pmod(),
    .gpio()
  );

  task testcase;
    logic [7:0] xmt [2];
    logic [1:0][7:0] rcv;
    logic [1:0][7:0] exp;
    repeat (1) begin
      for (int i = 0; i < 2; i++) xmt[i] = random(2**8-1);
      exp = $signed(xmt[0]) * $signed(xmt[1]);
      fork
        for (int i = 0; i < 2; i++) stx(xmt[i]);
        for (int i = 0; i < 2; i++) srx(rcv[i]);
      join
      `check_equal(rcv, exp);
    end
  endtask : testcase

  task test;
  fork
    begin : timeout
      repeat (1e6) @(posedge clk);
      disable worker;
      `ifdef __ICARUS__
        $error("testbench timeout");
        $stop;
      `else
        $fatal(0, "testbench timeout");
      `endif
    end : timeout
    begin : worker
      testcase;
      disable timeout;
    end : worker
  join
  endtask : test

  initial begin
    dump;
    seed;
    #PERIOD;
    test;
    $finish;
  end

endmodule
