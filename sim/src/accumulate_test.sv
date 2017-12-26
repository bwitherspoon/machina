`include "check.svh"
`include "clock.svh"
`include "connect.svh"
`include "dump.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 16;

  localparam int MAX = 2**(W-1)-1;
  localparam int MIN = -(2**(W-1));

  `clock()
  `reset
  `master(W)
  `slave(W)

  accumulate #(W) uut (.*);

  task test;
    logic [W-1:0] arg [4];
    logic [W-1:0] exp;
    logic [W-1:0] res;
    int sum;
    begin
      sum = 0;
      foreach (arg[i]) begin
        arg[i] = random(2**W);
        sum += $signed(arg[i]);
        if (sum < MIN)
          sum = MIN;
        else if (sum > MAX)
          sum = MAX;
      end
      exp = sum[W-1:0];
      fork
        for (int i = 0; i < 4; i++) s_put(arg[i]);
        for (int i = 0; i < 4; i++) m_get(res);
      join
      `check_equal(res, exp);
    end
  endtask : test

  task run;
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
