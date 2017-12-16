`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "reset.svh"
`include "check.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam CNT = 8;

  `clock()
  `reset
  `slave(, $clog2(CNT))

  count #(CNT) uut (.*);

  task testcase;
    logic [$clog2(CNT)-1:0] cnt;
    begin
      for (int idx = 0; idx < CNT; idx = idx + 1) begin
        rcv(cnt);
        `check_equal(cnt, idx);
      end
      rcv(cnt);
      `check_equal(cnt, 0);
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
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
