module logistic_test;
  timeunit 1ns;
  timeprecision 1ps;

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic argument_valid = '0;
  logic argument_ready;
  logic [15:0] argument_data;

  logic feedback_valid = '0;
  logic feedback_ready;
  logic [15:0] feedback_data;

  logic activation_valid;
  logic activation_ready = '0;
  logic [7:0] activation_data;

  logic delta_valid;
  logic delta_ready = '0;
  logic [15:0] delta_data;

  logic [7:0] activation;
  logic [15:0] delta;

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
    .activation_valid(activation_valid),
    .activation_data(activation_data),
    .activation_ready(activation_ready),
    .delta_valid(delta_valid),
    .delta_data(delta_data),
    .delta_ready(delta_ready)
  );

  initial begin
`ifdef DUMPFILE
    $dumpfile(`"`DUMPFILE`");
    $dumpvars;
`endif

    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;

    @ (negedge clock) argument_valid = 1;
    argument_data = 0;
    wait (argument_ready == 1) @ (posedge clock);
    #1 argument_valid = 0;

    wait (activation_valid == 1) #1 activation_ready = 1;
    @ (posedge clock) activation = activation_data;
    if (activation != 8'h80)
      $fatal(0, "activation invalid: %h", activation);
    #1 activation_ready = 0;

    wait (argument_ready == 1) @ (posedge clock) #1 train = 1;

    argument_valid = 1;
    argument_data = 6 <<< 8;
    wait (argument_ready == 1) @ (posedge clock);
    #1 argument_valid = 0;

    wait (activation_valid == 1) #1 activation_ready = 1;
    @ (posedge clock) activation = activation_data;
    if (activation != 8'hff)
      $fatal(0, "activation invalid: %h", activation);
    #1 activation_ready = 0;

    feedback_valid = 1;
    feedback_data = -(2**8) - 2**8;
    wait (feedback_ready == 1) @ (posedge clock);
    #1 feedback_valid = 0;

    wait (delta_valid == 1) #1 delta_ready = 1;
    @ (posedge clock) delta = delta_data;
    if (delta != 8'h00)
      $fatal(0, "delta invalid: %h", delta);
    #1 delta_ready = 0;

    $finish(0);
  end

endmodule
