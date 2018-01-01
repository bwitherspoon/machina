`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "connect.svh"
`include "random.svh"
`include "reset.svh"
`include "utility.svh"

module testbench #(
  parameter TIMEOUT = 1e6
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 16;
  localparam N = 4;
  localparam Q = 8;

  `clock()
  `reset
  `connect(r, s_d, W)
  `connect(m_a, ar, $clog2(N))
  `slave(W,, N, s_i)
  `master(W,,, m_o)

  forward #(W, N, Q) uut (.*);

  memory #(W, N) mem (
    .*,
    .aw_stb(1'b0),
    .aw_dat({$clog2(N){1'bz}}),
    .aw_rdy(),
    .w_stb(1'b0),
    .w_dat({W{1'bz}}),
    .w_rdy()
  );

  task test;
    logic [W-1:0] dat[N];
    logic [W-1:0] exp;
    logic [W-1:0] out;
    begin
      foreach (dat[n]) dat[n] = random(2**8);
      exp = 0;
      foreach (dat[n]) exp += dat[n] * mem.mem[n] >>> Q;
      fork
        foreach (dat[n]) s_i_put(dat[n], n);
        m_o_get(out);
      join
      `check_equal(out, exp);
    end
  endtask : test

  task init;
  begin
    for (int n = 0; n < N + 1; n++)
      mem.mem[n] = 2**Q-1;
  end
  endtask : init

  task run;
  fork
    begin : timeout
      repeat (TIMEOUT) @(posedge clk);
      disable worker;
      `ifdef __ICARUS__
        $error("testbench timeout");
        $stop;
      `else
        $fatal(0, "testbench timeout");
      `endif
    end : timeout
    begin : worker
      init;
      test;
      disable timeout;
    end : worker
  join
  endtask : run

  initial begin
    dump;
    seed;
    run;
    reset;
    run;
    $finish;
  end

endmodule
