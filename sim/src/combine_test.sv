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
  localparam N = 4;

  `clock()
  `reset
  `master(s_, W,, N)
  `slave(m_, W*N)

  combine #(W, N) uut (.*);

  task testcase;
    logic [N-1:0][W-1:0] dat;
    logic [N-1:0][W-1:0] out;
    repeat (8) begin
      for (int n = 0; n < N; n++)
        dat[n] = random(2**W-1);
      fork
        #(0*PERIOD+1) s_xmt(dat[0], 0);
        #(1*PERIOD+1) s_xmt(dat[1], 1);
        #(2*PERIOD+1) s_xmt(dat[2], 2);
        #(3*PERIOD+1) s_xmt(dat[3], 3);
        m_rcv(out);
      join
      `check_equal(out, dat);
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
