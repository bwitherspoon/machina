module logistic_test;
`include "test.svh"

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic argument_valid = 0;
  logic argument_ready;
  logic [15:0] argument_data;

  logic feedback_valid = 0;
  logic feedback_ready;
  logic [15:0] feedback_data;

  logic result_valid;
  logic result_ready = 0;
  logic [7:0] result_data;

  logic delta_valid;
  logic delta_ready = 0;
  logic [15:0] delta_data;

  logic [7:0] a;
  logic [15:0] d;

  logistic dut (
    .clock(clock),
    .reset(reset),
    .train(train),
    .argument_valid(argument_valid),
    .argument_data(argument_data),
    .argument_ready(argument_ready),
    .feedback_valid(feedback_valid),
    .feedback_data(feedback_data),
    .feedback_ready(feedback_ready),
    .activation_valid(result_valid),
    .activation_data(result_data),
    .activation_ready(result_ready),
    .delta_valid(delta_valid),
    .delta_data(delta_data),
    .delta_ready(delta_ready)
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
    argument(0);
    result(a);
    if (a != 8'h80) begin
      $error("result invalid: %h", a);
      $stop;
    end
    // Test 2
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    train = 1;
    argument(6 <<< 8);
    result(a);
    if (a != 8'hff) begin
      $error("result invalid: %h", a);
      $stop;
    end
    feedback(-(2**8) - 2**8);
    delta(d);
    if (d != 8'h00) begin
      $error("delta invalid: %h", d);
      $stop;
    end
    // Success
    $finish;
  end

endmodule
