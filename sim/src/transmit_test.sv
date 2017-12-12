`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"
`include "serial.svh"
`include "test.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam FREQ = 12e6;
  localparam BAUD = 96e2;

  `clock(FREQ)
  `reset
  `master()
  `serial(BAUD)

  transmit #(BAUD, FREQ) uut (.*);

  task testcase;
    logic [7:0] tx;
    logic [7:0] rx;
    begin
      for (int i = 0; i < 2; i++) begin
        tx = random(255);
        xmt(tx);
        srx(rx);
        `test_equal(rx, tx);
      end
    end
  endtask

  task test;
    fork
      begin : timeout
        repeat (1e6) @(posedge clk);
        disable worker;
        $error("testbench timeout");
        $stop;
      end : timeout
      begin : worker
        testcase;
        disable timeout;
      end : worker
    join
  endtask

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
