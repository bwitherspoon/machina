`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "connect.svh"
`include "random.svh"
`include "reset.svh"
`include "utility.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 8;
  localparam N = 2;

  `clock()
  `reset
  `slave(W,, N+1)
  `master(2*W,, 2)

  inner #(W, N) uut (.*);

  task basic;
    logic [W-1:0] dat;
    logic [2*W-1:0] out;
    fork
      for (int n = 0; n < N; n++) begin
        dat = random(2**W-1);
        s_put(dat, n);
      end
      m_get(out);
    join
  endtask : basic

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
      basic;
      disable timeout;
    end : worker
  join
  endtask : test

  task init;
  begin
    for (int i = 0; i < N + 1; i++)
      uut.wts.mem[i] = random(2**4);
  end
  endtask : init

  initial begin
    dump;
    seed;
    init;
    test;
    $finish;
  end

endmodule
