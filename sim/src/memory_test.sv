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
  `slave($clog2(D),,, waddr)
  `slave(W,,, wdata)
  `slave($clog2(D),,, raddr)
  `master(W,,, rdata)

  memory #(W, D) uut (.*);

  task testcase;
    logic [W-1:0] wdata [D];
    logic [W-1:0] rdata [D];
    begin
      for (int i = 0; i < D; i++) begin
        wdata[i] = random(2**W-1);
        fork
          waddr_put(i[$clog2(D)-1:0]);
          wdata_put(wdata[i]);
        join
      end
      for (int i = 0; i < D; i++) begin
        fork
          raddr_put(i[$clog2(D)-1:0]);
          rdata_get(rdata[i]);
        join
        `check_equal(rdata[i], wdata[i]);
      end
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
