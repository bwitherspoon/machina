`include "check.svh"
`include "clock.svh"
`include "connect.svh"
`include "dump.svh"
`include "reset.svh"

module testbench #(
  parameter TIMEOUT = 1e6
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 32;
  localparam M = 4;

  `clock()
  `reset
  `slave(W)
  `master(W)

  decimate #(W, M) uut (.*);

  task test;
    logic [W-1:0] dat;
    repeat (8) begin
      fork
        for (int m = 0; m < M; m++)
          s_put(m[0+:W]);
        m_get(dat);
      join
      `check_equal(dat, M-1);
    end
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
