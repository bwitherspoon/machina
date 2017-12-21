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
  `master(s_, W, D)
  `slave(m_, W)

  unpack #(W, D) uut (.*);

  task testcase;
    logic [D-1:0][W-1:0] arg;
    logic [W-1:0] out;
    repeat (8) begin
      for (int idx = 0; idx < D; idx++)
        arg[idx] = random(2**W-1);
      fork
        s_xmt(arg);
        for (int idx = 0; idx < D; idx++) begin
          m_rcv(out);
          `check_equal(out, arg[idx]);
        end
      join
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
