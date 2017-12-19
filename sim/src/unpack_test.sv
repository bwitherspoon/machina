`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 8;
  localparam ARGD = 4;

  `clock()
  `reset
  `master(arg_, ARGW, ARGD)
  `slave(out_, ARGW)

  unpack #(ARGW, ARGD) uut (.*);

  task testcase;
    logic [ARGD-1:0][ARGW-1:0] arg;
    logic [ARGW-1:0] out;
    repeat (8) begin
      for (int idx = 0; idx < ARGD; idx++)
        arg[idx] = random(2**ARGW-1);
      fork
        arg_xmt(arg);
        for (int cnt = 0; cnt < ARGD; cnt++) begin
          out_rcv(out);
          `check_equal(out, arg[cnt]);
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
