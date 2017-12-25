`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 8;

  `clock()
  `reset
  `master(s_, W, 2)
  `slave(m_, 2*W)

  multiply #(W) uut (.*);

  task testcase;
    logic [1:0][W-1:0] arg;
    logic [2*W-1:0] exp;
    logic [2*W-1:0] res;
    repeat (8) begin
      arg[0] = random(2**W);
      arg[1] = random(2**W);
      exp = $signed(arg[0]) * $signed(arg[1]);
      fork
        s_xmt(arg);
        m_rcv(res);
      join
      `check_equal(res, exp);
    end
  endtask : testcase

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
