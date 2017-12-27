`include "check.svh"
`include "dump.svh"
`include "random.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 16;
  localparam L = 8;

  localparam int MAX = 2**(L-1)-1;
  localparam int MIN = -(2**(L-1));

  logic signed [W-1:0] i;
  logic signed [W-1:0] o;

  saturate #(W, L) uut (.*);

  task test;
    int s;
    repeat (25) begin
      i = random(2**L);
      s = MIN < i ? i < MAX ? i : MAX : MIN;
      #1 `check_equal(o, s[W-1:0]);
    end
  endtask

  initial begin
    dump;
    seed;
    test;
    $finish;
  end

endmodule
