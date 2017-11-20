module logistic_test;
`include "test.svh"

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic argument_valid = 0;
  logic argument_ready;
  logic [15:0] argument_data;

  logic result_valid;
  logic result_ready = 0;
  logic [7:0] result_data;

  logic error_valid = 0;
  logic error_ready;
  logic [15:0] error_data;

  logic propagate_valid;
  logic propagate_ready = 0;
  logic [15:0] propagate_data;

  logic [7:0] res;
  logic [15:0] prp;

  logistic dut (
    .clock(clock),
    .reset(reset),
    .train(train),
    .argument_valid(argument_valid),
    .argument_data(argument_data),
    .argument_ready(argument_ready),
    .error_valid(error_valid),
    .error_data(error_data),
    .error_ready(error_ready),
    .activation_valid(result_valid),
    .activation_data(result_data),
    .activation_ready(result_ready),
    .propagate_valid(propagate_valid),
    .propagate_data(propagate_data),
    .propagate_ready(propagate_ready)
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
    test(res == 8'h80);
    // Test 2
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    train = 1;
    forward(6 <<< 8, res);
    test(res == 8'hff);
    backward(-(2**8) - 2**8, prp);
    test(prp == 8'h00);
    // Success
    $finish;
  end

endmodule
