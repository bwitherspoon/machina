`include "check.svh"
`include "clock.svh"
`include "connect.svh"
`include "dump.svh"
`include "random.svh"
`include "reset.svh"

module testbench #(
  parameter [31:0] R = 8
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 8;
  localparam N = 4;

  `clock()
  `reset
  `slave(W)
  `slave($clog2(N),,, n)
  `master(W,, N)

  demultiplex #(W, N) uut (.*);

  task testcase;
    logic [W-1:0] dat;
    logic [$clog2(N)-1:0] sel;
    logic [W-1:0] out;
    repeat (R) begin
      dat = random(2**W);
      sel = random(N);
      fork
        n_put(sel);
        s_put(dat);
        m_get(out, sel);
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
