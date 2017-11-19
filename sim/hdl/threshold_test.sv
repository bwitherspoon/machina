module threshold_test;
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

  threshold dut (
    .clock(clock),
    .reset(reset),
    .train(train),
    .argument_valid(argument_valid),
    .argument_data(argument_data),
    .argument_ready(argument_ready),
    .result_valid(result_valid),
    .result_data(result_data),
    .result_ready(result_ready),
    .error_valid(error_valid),
    .error_data(error_data),
    .error_ready(error_ready),
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
    if (res != 8'hff) begin
      $display("ERROR: result invalid: %h", res);
      $stop;
    end
    // Test 2
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    train = 1;
    forward(-1, res);
    if (res != 8'h00) begin
      $display("ERROR: result invalid: %h", res);
      $stop;
    end
    backward(-1, prp);
    if ($signed(prp) != -1) begin
      $display("ERROR: propagation invalid: %h", prp);
      $stop;
    end
    // Success
    $finish;
  end
endmodule
