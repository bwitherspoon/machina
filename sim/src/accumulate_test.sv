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

  `clock()
  `reset
  `master(W)
  `slave(W)

  accumulate #(W) uut (.*);

  task basic;
    logic [W-1:0] arg[4];
    logic signed [W-1:0] exp;
    logic [W-1:0] res;
    begin
      exp = 0;
      for (int i = 0; i < 4; i++) begin
        arg[i] = random(2**W-1);
        exp += $signed(arg[i]);
      end
      fork
        for (int i = 0; i < 4; i++) s_put(arg[i]);
        m_get(res);
      join
    end
  endtask : basic

  task clear;
    fork
      begin : xmt
        logic [W-1:0] arg [4];
        int i;
        arg[0] = 16'h00ff; arg[1] = 16'h0001;
        arg[2] = 16'hffff; arg[3] = 16'h000f;
        for (i = 0; i < 3; i++) s_put(arg[i]);
        repeat (2) @(posedge clk);
        @(negedge clk) s_put(arg[3]);
      end : xmt
      begin : rcv
        logic [W-1:0] res;
        m_get(res);
        `check_equal(res, 16'h00ff);
        m_get(res);
        `check_equal(res, 16'h000f);
      end : rcv
    join
  endtask : clear

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
        basic;
        clear;
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
