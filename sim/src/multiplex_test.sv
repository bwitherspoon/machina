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
  `master(W+$clog2(N))

  multiplex #(W, N) uut (.*);

  task test;
    localparam K = 16*N;
    logic [$clog2(N)-1:0] sel[K], adr;
    logic [W-1:0] arg[K], dat;
    begin
      foreach (sel[k]) sel[k] = random(N);
      foreach (arg[k]) arg[k] = random(2**W);
      fork
        foreach (sel[k]) s_put(arg[sel[k]], sel[k]);
        repeat (K) begin
          m_get({adr, dat});
          `check_equal(dat, arg[adr]);
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
