`include "check.svh"
`include "clock.svh"
`include "connect.svh"
`include "dump.svh"
`include "random.svh"
`include "reset.svh"

module testbench #(
  parameter TIMEOUT = 1e6
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 8;
  localparam N = 8;

  `clock()
  `reset
  `slave(W)
  `master(W,, N)

  distribute #(W, N) uut (.*);

  task test;
    logic [W-1:0] dat;
    logic [W-1:0] out [N];
    repeat (25) begin
      dat = random(2**W);
      fork
        s_put(dat);
        foreach (out[n]) m_get(out[n], n);
      join
      foreach (out[n]) `check_equal(out[n], dat);
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
    seed;
    #PERIOD;
    run;
    reset;
    run;
    $finish;
  end

endmodule
