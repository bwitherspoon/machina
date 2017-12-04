`include "debug.vh"

module multiply_test;
  `define ARGW 16
  `define ARGD 2
  `define RESW 32
  `include "test.svh"

  multiply uut (.*);

  logic [RESW-1:0] res;

  task test;
    begin
      forward(32'h_0080_0080, res);
      `ASSERT_EQUAL(res, 32'h4000);
      forward(32'h_0100_0100, res);
      `ASSERT_EQUAL(res, 32'h10000);
      forward(32'h_7fff_0000, res);
      `ASSERT_EQUAL(res, 32'b0);
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
