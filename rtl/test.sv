module test;
  timeunit 1ns;
  timeprecision 1ps;

  // Clock (100 MHz)
  bit clock;
  always #5 clock <= ~clock;

  // Reset
  bit reset;

  // Signals
  logic train;

  logic input_forward_valid;
  logic input_forward_ready;
  logic [1:0][7:0] input_forward_data;

  logic input_backward_valid;
  logic input_backward_ready;
  logic [15:0] input_backward_data;

  logic output_forward_valid;
  logic output_forward_ready;
  logic [7:0] output_forward_data;

  logic output_backward_valid;
  logic output_backward_ready;
  logic [1:0][15:0] output_backward_data;

  logic signed [1:0][7:0] stimulus [4];
  logic signed [15:0] result;
  logic signed [15:0] target [4];

  // DUT
  node #(.WIDTH(8), .DEPTH(2)) dut (
    .clock(clock),
    .reset(reset),
    .train(train),
    .input_valid(input_forward_valid),
    .input_data(input_forward_data),
    .input_ready(input_forward_ready),
    .input_backprop_valid(input_backward_valid),
    .input_backprop_data(input_backward_data),
    .input_backprop_ready(input_backward_ready),
    .output_valid(output_forward_valid),
    .output_data(output_forward_data),
    .output_ready(output_forward_ready),
    .output_backprop_valid(output_backward_valid),
    .output_backprop_data(output_backward_data),
    .output_backprop_ready(output_backward_ready)
  );

  initial begin
    $dumpfile("test.vcd");
    $dumpvars;
    stimulus[0] = 16'h8080;
    stimulus[1] = 16'h807F;
    stimulus[2] = 16'h7F80;
    stimulus[3] = 16'h7F7F;
    target[0] = 16'h0000;
    target[1] = 16'h0000;
    target[2] = 16'h0000;
    target[3] = 16'h0000;
    train = 0;
    reset = 1;
    input_forward_valid = 0;
    input_backward_valid = 0;
    output_forward_ready = 0;
    output_backward_ready = 0;
    #20 reset = 0;
    train = 1;
    $info("Running...");
    repeat (1000) begin
      for (int i = 0; i < 4; i++) begin
        input_forward_valid = 1;
        input_forward_data = stimulus[i];
        wait (input_forward_ready == 1) @(posedge clock);
        #1 input_forward_valid = 0;

        wait (output_forward_valid == 1) output_forward_ready = 1;
        @(posedge clock) result = output_forward_data;
        #1 output_forward_ready = 0;

        input_backward_valid = 1;
        input_backward_data = target[i] - result;
        wait (input_backward_ready == 1) @(posedge clock);
        #1 input_backward_valid = 0;

        wait (output_backward_valid == 1) output_forward_ready = 1;
        @(posedge clock) #1 output_backward_ready = 0;
      end
    end
    $info("Finished");
    $finish(0);
  end

endmodule
