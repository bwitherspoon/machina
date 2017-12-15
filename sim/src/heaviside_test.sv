`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 16;
  localparam RESW = 8;
  localparam ERRW = 16;
  localparam FBKW = 16;

  `clock()
  `reset
  `master(arg_, ARGW)
  `slave(res_, RESW)
  `master(err_, ERRW)
  `slave(fbk_, FBKW)

  logic en;

  heaviside uut (.*);

  task fwd;
    logic [RESW-1:0] res;
    begin
      en = 0;
      arg_xmt(0);
      res_rcv(res);
      `check_equal(res, 8'hff);
    end
  endtask

  task bwd;
    logic [RESW-1:0] res;
    logic [FBKW-1:0] fbk;
    begin
      en = 1;
      arg_xmt(-1);
      res_rcv(res);
      `check_equal(res, 8'h00);
      err_xmt(-1);
      fbk_rcv(fbk);
      `check_equal($signed(fbk), -1);
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
        fwd;
        bwd;
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
