`include "debug.vh"

module top;
  `define ARGW 16
  `define ARGN 4
  `define RESW 18
  `define RESK `ARGN
  `include "test.svh"

  serialize #(.ARGW(ARGW), .ARGN(ARGN)) uut (.*);

  logic [ARGN-1:0][ARGD-1:0][ARGW-1:0] arg;
  logic [RESK-1:0][RESD-1:0][RESW-1:0] res;

  task test;
    begin
      for (int n = 0; n < ARGN; n++)
        arg[n] = n;
      forward(arg, res);
      for (int k = 0; k < RESK; k++)
        `ASSERT_EQUAL(res[k], ({k[$clog2(ARGN)-1:0], k[ARGW-1:0]}));
    end
  endtask

  initial begin
    dump;
    test;
    reset;
    test;
    $finish;
  end
endmodule
