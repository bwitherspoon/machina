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
`ifdef DUMPFILE
    $dumpfile(`"`DUMPFILE`");
    $dumpvars;
`endif
    // Test 1
    en = 0;
    forward_pass(0, res);
    `TESTBENCH_ASSERT(res === 8'h80);
    forward_pass(6 * 2**8, res);
    `TESTBENCH_ASSERT(res === 8'hff);
    forward_pass(-6 * 2**8 - 1, res);
    `TESTBENCH_ASSERT(res === 8'h00);
    // Test 2
    reset();
    en = 1;
    forward_pass(6 * 2**8, res);
    `TESTBENCH_ASSERT(res === 8'hff);
    backward_pass(-(2**8) - 2**8, fbk);
    `TESTBENCH_ASSERT(fbk === 16'h0000);
    // Success
    $finish;
  end

endmodule
