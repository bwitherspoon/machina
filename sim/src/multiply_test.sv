`include "clock.svh"
`include "debug.vh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 16;
  localparam RESW = 2*ARGW;

  `clock()
  `reset
  `master(arg_, ARGW, 2)
  `slave(res_, RESW)

  multiply #(ARGW) uut (.*);

  task testcase;
    logic [1:0][ARGW-1:0] arg;
    logic [1:0][RESW-1:0] res;
    repeat (8) begin
      arg[0] = random(2**16-1);
      arg[1] = random(2**16-1);
      res[0] = $signed(arg[0]) * $signed(arg[1]);
      arg_xmt(arg);
      res_rcv(res[1]);
      `ASSERT_EQUAL(res[0], res[1]);
    end
  endtask

  task test;
    fork
      begin : timeout
        repeat (1e6) @(posedge clk);
        disable worker;
        $error("testbench timeout");
        $stop;
      end : timeout
      begin : worker
        testcase;
        disable timeout;
      end : worker
    join
  endtask

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
