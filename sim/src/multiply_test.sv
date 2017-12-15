`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"
`include "test.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 16;
  localparam ARGC = 2;
  localparam RESW = 2*ARGW;

  `clock()
  `reset
  `master(arg_, ARGW,, ARGC)
  `slave(res_, RESW)

  multiply #(ARGW) uut (.*);

  task testcase0;
    logic [1:0][ARGW-1:0] arg;
    logic [1:0][RESW-1:0] res;
    repeat (8) begin
      arg[0] = random(2**16-1);
      arg[1] = random(2**16-1);
      res[0] = $signed(arg[0]) * $signed(arg[1]);
      for (int i = 0; i < 2; i++) arg_xmt(arg[i], i);
      res_rcv(res[1]);
      `test_equal(res[0], res[1]);
    end
  endtask

  task testcase1;
    logic [1:0][ARGW-1:0] arg;
    logic [1:0][RESW-1:0] res;
    repeat (8) begin
      arg[0] = random(2**16-1);
      arg[1] = random(2**16-1);
      res[0] = $signed(arg[0]) * $signed(arg[1]);
      fork
        for (int i = 0; i < 2; i++) arg_xmt(arg[i], i);
        res_rcv(res[1]);
      join
      `test_equal(res[0], res[1]);
    end
  endtask

  task testcase2;
    logic [1:0][ARGW-1:0] arg;
    logic [1:0][RESW-1:0] res;
    repeat (8) begin
      arg[0] = random(2**16-1);
      arg[1] = random(2**16-1);
      res[0] = $signed(arg[0]) * $signed(arg[1]);
      fork
        arg_xmt(arg[0], 0);
        arg_xmt(arg[1], 1);
        res_rcv(res[1]);
      join
      `test_equal(res[0], res[1]);
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
        testcase0;
        testcase1;
        testcase2;
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
