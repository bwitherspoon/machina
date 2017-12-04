`include "debug.vh"

module accumulate_test;
  `define ARGW 24
  `define RESW 40
  `include "test.svh"

  logic clr = 0;

  accumulate #(.ARGW(ARGW), .RESW(RESW)) uut (.*);

  logic [RESW-1:0] res;

  task test;
    begin
      forward(24'h000ff, res);
      `ASSERT_EQUAL(res, 40'h00ff);
      forward(24'h000001, res);
      `ASSERT_EQUAL(res, 40'h0100);
      forward(24'hffffff, res);
      `ASSERT_EQUAL(res, 40'h00ff);
      clr = 1;
      forward(24'h00000f, res);
      `ASSERT_EQUAL(res, 40'h000f);
      clr = 0;
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
