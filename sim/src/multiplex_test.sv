`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 16;
  localparam ARGC = 4;

  `clock()
  `reset
  `master(arg_, ARGW,, ARGC)
  `master(sel_, $clog2(ARGC))
  `slave(out_, ARGW)

  multiplex #(ARGW, ARGC) uut (.*);

  task testcase0;
    logic [ARGW-1:0] arg;
    logic [$clog2(ARGC)-1:0] sel;
    logic [ARGW-1:0] out;
    repeat (8) begin
      arg = random(2**ARGW-1);
      sel = random(ARGC);
      fork
        arg_xmt(arg, sel);
        sel_xmt(sel);
      join
      out_rcv(out);
      `check_equal(out, arg);
    end
  endtask : testcase0

  task testcase1;
    logic [ARGW-1:0] arg;
    logic [$clog2(ARGC)-1:0] sel;
    logic [ARGW-1:0] out;
    repeat (8) begin
      arg = random(2**ARGW-1);
      sel = random(ARGC);
      fork
        #(PERIOD+1) arg_xmt(arg, sel);
        sel_xmt(sel);
      join
      out_rcv(out);
      `check_equal(out, arg);
    end
  endtask : testcase1

  task testcase2;
    logic [ARGW-1:0] arg;
    logic [$clog2(ARGC)-1:0] sel;
    logic [ARGW-1:0] out;
    repeat (8) begin
      arg = random(2**ARGW-1);
      sel = random(ARGC);
      fork
        arg_xmt(arg, sel);
        #(PERIOD+1) sel_xmt(sel);
      join
      out_rcv(out);
      `check_equal(out, arg);
    end
  endtask : testcase2

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
      testcase0;
      testcase1;
      testcase2;
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
