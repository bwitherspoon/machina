module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  `include "clock.svh"
  `include "debug.vh"
  `include "dump.svh"
  `include "interface.svh"
  `include "random.svh"
  `include "reset.svh"
  `include "serial.svh"

  `xmt()
  `srx()
  transmit #(BAUDRATE, FREQUENCY) uut (.*);

  task testcase;
    logic [7:0] tx;
    logic [7:0] rx;
    begin
      for (int i = 0; i < 2; i++) begin
        tx = random(255);
        xmt(tx);
        srx(rx);
        `ASSERT_EQUAL(rx, tx);
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
