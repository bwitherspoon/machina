`include "check.svh"
`include "clock.svh"
`include "connect.svh"
`include "dump.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 16;
  localparam D = 256;

  `clock()
  `reset
  `slave($clog2(D),,, aw)
  `slave(W,,, w)
  `slave($clog2(D),,, ar)
  `master(W,,, r)

  memory #(W, D) uut (.*);

  task test;
    logic [W-1:0] wr [D];
    logic [W-1:0] rd [D];
    begin
      for (int i = 0; i < D; i++) begin
        wr[i] = random(2**W);
        fork
          aw_put(i[$clog2(D)-1:0]);
          w_put(wr[i]);
        join
      end
      for (int i = 0; i < D; i++) begin
        fork
          ar_put(i[$clog2(D)-1:0]);
          r_get(rd[i]);
        join
        `check_equal(rd[i], wr[i]);
      end
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
