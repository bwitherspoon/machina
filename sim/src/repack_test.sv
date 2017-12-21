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
  localparam D = 4;

  `clock()
  `reset
  `master(s_, W)
  `slave(m_, W*D)

  repack #(W, D) uut (.*);

  task testcase;
    logic [D-1:0][W-1:0] arg;
    logic [D*W-1:0] out;
    repeat (1) begin
      fork
        for (int i = 0; i < D; i++) begin
          arg[i] = random(2**W-1);
          s_xmt(arg[i]);
        end
        m_rcv(out);
      join
      `check_equal(out, arg);
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
    seed;
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
