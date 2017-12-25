`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 8;
  localparam D = 2;

  `clock()
  `reset
  `master(s_, W)
  `slave(m_, W*D)

  repack #(W, D) uut (.*);

  task basic;
    logic [D-1:0][W-1:0] arg;
    logic [D*W-1:0] out;
    repeat (8) begin
      fork
        for (int i = 0; i < D; i++) begin
          arg[i] = random(2**W);
          s_xmt(arg[i]);
        end
        m_rcv(out);
      join
      `check_equal(out, arg);
    end
  endtask : basic

  task strobe;
    logic [D*W-1:0] out;
    begin
      m_rdy = 1;
      for (int i = 0; i < D; i++)
        s_xmt(random(2**W));
      s_stb = 1;
      do wait (m_stb) @(posedge clk); while (~m_stb);
      #(PERIOD+1) `check_equal(m_stb, 0);
    end
  endtask : strobe

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
      strobe;
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
