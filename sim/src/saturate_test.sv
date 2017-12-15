`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 24;
  localparam RESW = 16;

  `clock()
  `reset
  `master(arg_, ARGW)
  `slave(res_, RESW)

  saturate #(.ARGW(ARGW), .RESW(RESW)) uut (.*);

  task testcase;
    logic [ARGW-1:0] arg [4];
    logic [RESW-1:0] exp [4];
    logic [RESW-1:0] res;
    begin
      arg[0] = 24'h0000ff; arg[1] = 24'hffff00; arg[2] = 24'h7fffff; arg[3] = 24'h800000;
      exp[0] = 16'h00ff; exp[1] = 16'hff00; exp[2] = 16'h7fff; exp[3] = 16'h8000;
      for (int i = 0; i < 4; i++) begin
        arg_xmt(arg[i]);
        res_rcv(res);
        `check_equal(res, exp[i]);
      end
    end
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
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
