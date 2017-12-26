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
  localparam N = 4;

  `clock()
  `reset
  `slave(W, N)
  `master(W,, N)

  seperate #(W, N) uut (.*);

  task test;
    logic [N-1:0][W-1:0] dat;
    logic [N-1:0][W-1:0] out;
    begin
      for (int n = 0; n < N; n++) dat[n] = random(2**W);
      fork
        s_put(dat);
        for (int n = 0; n < N; n++) begin
          m_get(out[n], n);
          `check_equal(m_stb[n], 1'b0);
        end
      join
      `check_equal(out, dat);
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
