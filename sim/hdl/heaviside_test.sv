module heaviside_test;
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

  heaviside dut (
    .clock(clock),
    .reset(reset),
    .train(train),
    .arg_valid(arg_valid),
    .arg_data(arg_data),
    .arg_ready(arg_ready),
    .res_valid(res_valid),
    .res_data(res_data),
    .res_ready(res_ready),
    .err_valid(err_valid),
    .err_data(err_data),
    .err_ready(err_ready),
    .fbk_valid(fbk_valid),
    .fbk_data(fbk_data),
    .fbk_ready(fbk_ready)
  );

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
    `TEST(res == 8'hff);
    // Test 2
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    train = 1;
    forward(-1, res);
    `TEST(res == 8'h00);
    backward(-1, fbk);
    `TEST($signed(fbk) == -1);
    // Success
    $finish;
  end
endmodule
