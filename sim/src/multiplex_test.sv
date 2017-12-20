`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 16;
  localparam N = 4;

  `clock()
  `reset
  `master(s_, W,, N)
  `slave(m_, W+$clog2(N))

  multiplex #(W, N) uut (.*);

  task testcase;
    logic [W-1:0] dat;
    logic [$clog2(N)-1:0] sel;
    logic [W-1:0] out;
    repeat (8) begin
      dat = random(2**W-1);
      sel = random(N-1);
      fork
        s_xmt(dat, sel);
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
