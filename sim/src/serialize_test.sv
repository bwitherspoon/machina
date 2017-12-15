`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 16;
  localparam ARGC = 4;
  localparam RESW = 18;

  `clock()
  `reset
  `master(arg_, ARGW,, ARGC)
  `slave(res_, RESW)

  serialize #(.ARGW(ARGW), .ARGN(ARGC)) uut (.*);

  // FIXME iverilog 10 (not 11) seg faults with for loop local int in fork
  task testcase;
  fork
    begin : xmt
      int i;
      for (i = 0; i < ARGC; i++)
        arg_xmt(i[ARGW-1:0], i);
    end : xmt
    begin : rcv
      logic [RESW-1:0] exp;
      logic [RESW-1:0] res;
      int i;
      for (i = 0; i < ARGC; i++) begin
        res_rcv(res);
        exp = {i[$clog2(ARGC)-1:0], i[ARGW-1:0]};
        `check_equal(res, exp);
      end
    end : rcv
  join
  endtask

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
    test;
    reset;
    test;
    $finish;
  end

endmodule
