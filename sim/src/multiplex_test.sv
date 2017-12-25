`include "check.svh"
`include "clock.svh"
`include "dump.svh"
`include "connect.svh"
`include "random.svh"
`include "reset.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 16;
  localparam N = 4;

  `clock()
  `reset
  `slave(W,, N)
  `master(W+$clog2(N))

  multiplex #(W, N) uut (.*);

  task single;
    logic [$clog2(N)-1:0] sel;
    logic [W-1:0] dat, out;
    repeat (8) begin
      dat = random(2**W);
      sel = random(N);
      fork
        s_put(dat, sel);
        m_get(out);
      join
      `check_equal(out, dat);
    end
  endtask : single

  task multiple;
    localparam K = 10;
    logic [$clog2(N)-1:0] sel[K], adr;
    logic [W-1:0] dat[K], out;
    begin
      foreach (sel[k]) sel[k] = random(N);
      foreach (dat[k]) dat[k] = random(2**W);
      fork
        foreach (sel[k]) s_put(dat[sel[k]], sel[k]);
        repeat (K) begin
          m_get({adr, out});
          `check_equal(out, dat[adr]);
        end
      join
    end
  endtask : multiple

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
      //single;
      multiple;
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
