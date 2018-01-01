`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "connect.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 16;
  localparam N = 4;

  `clock()
  `reset
  `slave(W,, N)
  `master(W)
  `master($clog2(N),,, n)

  multiplex #(W, N) uut (.*);

  task test;
    localparam K = 16*N;
    logic [$clog2(N)-1:0] sel[K], n;
    logic [W-1:0] dat[K], d;
    begin
      foreach (sel[k]) sel[k] = random(N);
      foreach (dat[k]) dat[k] = random(2**W);
      fork
        foreach (sel[k]) s_put(dat[sel[k]], sel[k]);
        repeat (K) begin
          fork
            n_get(n);
            m_get(d);
          join
          `check_equal(d, dat[n]);
        end
      join
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
