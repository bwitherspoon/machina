`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "connect.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 8;

  `clock()
  `reset
  `slave(W,, 2)
  `master(2*W)

  multiply #(W) uut (.*);

  task test;
    logic [1:0][W-1:0] arg;
    logic [2*W-1:0] exp;
    logic [2*W-1:0] res;
    repeat (8) begin
      arg[0] = random(2**W);
      arg[1] = random(2**W);
      exp = $signed(arg[0]) * $signed(arg[1]);
      fork
        s_put(arg[0], 0);
        s_put(arg[1], 1);
        m_get(res);
      join
      `check_equal(res, exp);
    end
  endtask : test

  task run;
    fork
      begin : timeout
        repeat (1e6) @(posedge clk);
        disable worker;
        $error("testbench timeout");
        $stop;
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
