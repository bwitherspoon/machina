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

  localparam W = 8;
  localparam N = 2;

  `clock()
  `reset
  `connect(m_rd, s_d, 2*W)
  `connect(m_a, s_ra, $clog2(N+1))
  `slave(W,, N, s_i)
  `master(2*W,, N, m_o)

  forward #(W, N) uut (.*);

  memory #(2*W, N+1) mem (
    .*,
    .s_wa_stb(1'b0),
    .s_wa_dat({$clog2(N+1){1'bz}}),
    .s_wa_rdy(),
    .s_wd_stb(1'b0),
    .s_wd_dat({(2*W){1'bz}}),
    .s_wd_rdy()
  );

  task test;
    logic [W-1:0] dat[N];
    logic [2*W-1:0] exp;
    logic [2*W-1:0] out;
    begin
      foreach (dat[n]) dat[n] = random(2*W);
      exp = mem.mem[N];
      foreach (dat[n]) exp += (dat[n] * mem.mem[n]) >>> W;
      fork
        foreach (dat[n]) s_i_put(dat[n], n);
        m_o_get(out);
      join
      `check_equal(out, exp);
    end
  endtask : test

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
      test;
      disable timeout;
    end : worker
  join
  endtask : run

  task init;
  begin
    for (int i = 0; i < N + 1; i++)
      mem.mem[i] = random(2**W);
  end
  endtask : init

  initial begin
    dump;
    seed;
    init;
    run;
    reset;
    init;
    run;
    $finish;
  end

endmodule
