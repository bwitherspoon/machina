`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 24;
  localparam RESW = 40;

  `clock()
  `reset
  `master(arg_, ARGW)
  `slave(res_, RESW)

  accumulate #(.ARGW(ARGW), .RESW(RESW)) uut (.*);

  task testcase;
    fork
      begin : xmt
        logic [ARGW-1:0] arg [4];
        bit timeout;
        int i;
        arg[0] = 24'h0000ff; arg[1] = 24'h000001;
        arg[2] = 24'hffffff; arg[3] = 24'h00000f;
        for (i = 0; i < 3; i++) arg_xmt(arg[i]);
        repeat (2) @(posedge clk);
        @(negedge clk) arg_xmt(arg[3]);
      end : xmt
      begin : rcv
        logic [RESW-1:0] res;
        res_rcv(res);
        `check_equal(res, 40'h00000000ff);
        res_rcv(res);
        `check_equal(res, 40'h000000000f);
      end : rcv
    join
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
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
