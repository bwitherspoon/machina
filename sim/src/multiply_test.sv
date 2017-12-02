`include "debug.vh"

module multiply_test;
  `define ARGW 16
  `define RESW 24
  `include "test.svh"

  multiply uut (.*);

  logic [RESW-1:0] res;

  task test;
    begin
      // Test: 0.5 * 0.5 = 0.25
      forward(32'h_0080_0080, res);
      `ASSERT(res === 24'h40);
      // Test: 1.0 * 1.0 = 1.0
      forward(32'h_0100_0100, res);
      `ASSERT(res === 24'h100);
      // Test: ~128.0 * 0.0 = 0.0
      forward(32'h_7fff_0000, res);
      `ASSERT(res === 24'b0);
    end
  endtask

  initial begin
    dump;
    reset;
    test;
    $finish;
  end
endmodule
