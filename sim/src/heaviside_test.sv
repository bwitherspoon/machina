`include "debug.vh"

module heaviside_test;
  `define ARGW 16
  `define ARGN 1
  `define RESW 8
  `include "test.svh"

  heaviside uut (.*);

  logic [RESW-1:0] res;
  logic [FBKW-1:0] fbk;

  task fwd_test;
    begin
      en = 0;
      forward(0, res);
      `ASSERT(res === 8'hff);
    end
  endtask

  task bwd_test;
    begin
      en = 1;
      forward(-1, res);
      `ASSERT(res === 8'h00);
      backward(-1, fbk);
      `ASSERT($signed(fbk) === -1);
    end
  endtask

  initial begin
    dump;
    fwd_test;
    reset;
    bwd_test;
    $finish;
  end
endmodule
