module threshold_test;

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic argument_valid = 0;
  logic argument_ready;
  logic [15:0] argument_data;

  task argument;
    input [15:0] data;
    begin
      argument_valid = 1;
      argument_data = data;
      wait (argument_ready) @ (posedge clock);
      #1 argument_valid = 0;
    end
  endtask

  logic feedback_valid = 0;
  logic feedback_ready;
  logic [15:0] feedback_data;

  task feedback;
    input [15:0] data;
    begin
      feedback_valid = 1;
      feedback_data = data;
      wait (feedback_ready) @ (posedge clock);
      #1 feedback_valid = 0;
    end
  endtask

  logic activation_valid;
  logic activation_ready = 0;
  logic [7:0] activation_data;

  task activation;
    output [7:0] data;
    begin
      wait (activation_valid) #1 activation_ready = 1;
      @ (posedge clock) data = activation_data;
      #1 activation_ready = 1;
    end
  endtask

  logic delta_valid;
  logic delta_ready = 0;
  logic [15:0] delta_data;

  task delta;
    output [15:0] data;
    begin
      wait (delta_valid) #1 delta_ready = 1;
      @ (posedge clock) data = delta_data;
      #1 delta_ready = 1;
    end
  endtask

  logic [7:0] a;
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
    // Test 1
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    argument(0);
    activation(a);
    if (a != 8'hff) begin
      $display("ERROR: activation invalid: %h", a);
      $stop;
    end

    // Test 2
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    train = 1;
    argument(-1);
    activation(a);
    if (a != 8'h00) begin
      $display("ERROR: activation invalid: %h", a);
      $stop;
    end
    feedback(-1);
    delta(d);
    if ($signed(d) != -1) begin
      $display("ERROR: delta invalid: %h", d);
      $stop;
    end

    $finish;
  end


endmodule
