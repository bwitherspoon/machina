`include "check.svh"
`include "clock.svh"
`include "connect.svh"
`include "dump.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 8;
  localparam N = 4;

  `clock()
  `reset
  `slave(W,, N)
  `master($clog2(N)+W)

  reorder #(W, N) uut (.*);

  task testcase;
    int j, tmp, sel[N];
    logic [W-1:0] dat[N];
    logic [W-1:0] out;
    logic [$clog2(N)-1:0] adr;
    begin
      foreach (sel[i]) sel[i] = i;
      foreach (dat[i]) dat[i] = random(2**W-1);
      fork
        foreach (sel[i]) s_put(dat[sel[i]], sel[i]);
        foreach (dat[i]) begin
          m_get({adr, out});
          `check_equal(adr, i);
          `check_equal(out, dat[i]);
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
      testcase;
      disable timeout;
    end : worker
  join
  endtask : test

  initial begin
    dump;
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
