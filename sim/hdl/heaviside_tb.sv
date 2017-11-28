module heaviside_tb;
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

  heaviside uut (.*);

  initial begin
    dumpargs;
    // Test 1
    en = 0;
    forward(0, res);
    `ASSERT(res === 8'hff);
    // Test 2
    reset;
    en = 1;
    forward(-1, res);
    `ASSERT(res === 8'h00);
    backward(-1, fbk);
    `ASSERT($signed(fbk) === -1);
    // Success
    $finish;
  end
endmodule
