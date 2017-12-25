`include "clock.svh"
`include "dump.svh"
`include "reset.svh"

module testbench #(
  parameter TIMEOUT = 1e6
);
  timeunit 1ns;
  timeprecision 1ps;

  `clock()
  `reset

  task test;
    @(posedge clk);
  endtask : test

  task run;
  fork
    begin : timeout
      repeat (TIMEOUT) @(posedge clk);
      disable worker;
      `ifdef __ICARUS__
        $error("testbench timeout");
        $stop;
      `else
        $fatal(0, "testbench timeout");
      `endif
    end : timeout
    begin : worker
      test;
      disable timeout;
    end : worker
  join
  endtask : run

  initial begin
    dump;
    #PERIOD;
    run;
    reset;
    run;
    $finish;
  end

endmodule
