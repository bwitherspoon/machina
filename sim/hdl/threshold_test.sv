module threshold_test;

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

  logic activation_valid;
  logic activation_ready = 0;
  logic [7:0] activation_data;

  logic delta_valid;
  logic delta_ready = 0;
  logic [15:0] delta_data;

  logic [15:0] d;

  threshold dut (
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
    #20 reset = 0;

    #10 argument_valid = 1;
    argument_data = 0;
    wait (argument_ready == 1) @ (posedge clock);
    #1 argument_valid = 0;

    wait (activation_valid == 1) #1 activation_ready = 1;
    @ (posedge clock);
    if (activation_data != 8'hff) begin
      $display("ERROR: activation invalid: %h", activation_data);
      $stop;
    end
    #1 activation_ready = 0;

    wait (argument_ready == 1) @ (posedge clock) #1 train = 1;

    argument_valid = 1;
    argument_data = -1;
    wait (argument_ready == 1) @ (posedge clock);
    #1 argument_valid = 0;

    wait (activation_valid == 1) #1 activation_ready = 1;
    @ (posedge clock);
    if (activation_data != 8'h00) begin
      $display("ERROR: activation invalid: %h", activation_data);
      $stop;
    end
    #1 activation_ready = 0;

    feedback_valid = 1;
    feedback_data = -1;
    wait (feedback_ready == 1) @ (posedge clock);
    #1 feedback_valid = 0;

    wait (delta_valid == 1) #1 delta_ready = 1;
    @ (posedge clock) d = delta_data;
    if (d != feedback_data) begin
      $display("ERROR: delta invalid: %h", d);
      $stop;
    end
    #1 delta_ready = 0;

    $finish;
  end


endmodule
