module sigmoid_test;
`include "test.svh"

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic arg_valid = 0;
  logic arg_ready;
  logic [15:0] arg_data;

  logic res_valid;
  logic res_ready = 0;
  logic [7:0] res_data;

  logic err_valid = 0;
  logic err_ready;
  logic [15:0] err_data;

  logic fbk_valid;
  logic fbk_ready = 0;
  logic [15:0] fbk_data;

  logic [7:0] res;
  logic [15:0] fbk;

  sigmoid dut (.*);

  initial begin
`ifdef DUMPFILE
    $dumpfile(`"`DUMPFILE`");
    $dumpvars;
`endif
    // Test 1
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    forward(0, res);
    `TEST(res == 8'h80);
    // Test 2
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    train = 1;
    forward(6 <<< 8, res);
    `TEST(res == 8'hff);
    backward(-(2**8) - 2**8, fbk);
    `TEST(fbk == 8'h00);
    // Success
    $finish;
  end

endmodule
