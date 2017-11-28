module sigmoid_tb;
`include "testbench.svh"

  bit clk = 0;
  always #5 clk = ~clk;

  bit rst = 0;
  bit en = 0;

  logic arg_stb = 0;
  logic arg_rdy;
  logic [15:0] arg_dat;

  logic res_stb;
  logic res_rdy = 0;
  logic [7:0] res_dat;

  logic err_stb = 0;
  logic err_rdy;
  logic [15:0] err_dat;

  logic fbk_stb;
  logic fbk_rdy = 0;
  logic [15:0] fbk_dat;

  logic [7:0] res;
  logic [15:0] fbk;

  sigmoid uut (.*);

  initial begin
    dumpargs;
    // Test 1
    en = 0;
    forward(16'h0000, res);
    `TESTBENCH_ASSERT(res == 8'h80);
    forward(16'h07ff, res);
    `TESTBENCH_ASSERT(res == 8'hff);
    forward(16'hf800, res);
    `TESTBENCH_ASSERT(res == 8'h00);
    // Test 2 FIXME
    reset;
    en = 1;
    forward(0, res);
    `TESTBENCH_ASSERT(res == 8'h80);
    backward(255, fbk);
    `TESTBENCH_ASSERT(fbk == 16'h0040);
    // Success
    $finish;
  end

endmodule
