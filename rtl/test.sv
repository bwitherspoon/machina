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
  node #(.N(2), .K(3)) dut (
    .clock(clock),
    .reset(reset),
    .train(train),
    .input_forward_valid(input_forward_valid),
    .input_forward_data(input_forward_data),
    .input_forward_ready(input_forward_ready),
    .input_backward_valid(input_backward_valid),
    .input_backward_data(input_backward_data),
    .input_backward_ready(input_backward_ready),
    .output_forward_valid(output_forward_valid),
    .output_forward_data(output_forward_data),
    .output_forward_ready(output_forward_ready),
    .output_backward_valid(output_backward_valid),
    .output_backward_data(output_backward_data),
    .output_backward_ready(output_backward_ready)
  );

  initial begin
    $dumpfile("test.vcd");
    $dumpvars;
    stimulus[0] = 16'h0000;
    stimulus[1] = 16'h00FF;
    stimulus[2] = 16'hFF00;
    stimulus[3] = 16'hFFFF;
    target[0] = 16'h0000;
    target[1] = 16'h00FF;
    target[2] = 16'h0000;
    target[3] = 16'h00FF;
    train = 0;
    reset = 1;
    input_forward_valid = 0;
    input_backward_valid = 0;
    output_forward_ready = 0;
    output_backward_ready = 0;
    #20 reset = 0;
    train = 1;
    repeat (1000) begin
      for (int i = 0; i < 4; i++) begin
        input_forward_valid = 1;
        input_forward_data = stimulus[i];
        wait (input_forward_ready == 1) @(posedge clock);
        #1 input_forward_valid = 0;

        wait (output_forward_valid == 1) output_forward_ready = 1;
        @(posedge clock) result = output_forward_data;
        #1 output_forward_ready = 0;

        $display("%t: %2b: %5d * %5d + %5d * %5d + %5d = %5d -> %5d ? %5d ! %5d",
                 $time,
                 i[1:0],
                 dut.weight[1],
                 dut.operand[1],
                 dut.weight[0],
                 dut.operand[0],
                 dut.bias,
                 $signed(dut.accumulator[15:0]),
                 result,
                 target[i],
                 target[i] - result);

        input_backward_valid = 1;
        input_backward_data = target[i] - result;
        wait (input_backward_ready == 1) @(posedge clock);
        #1 input_backward_valid = 0;

        wait (output_backward_valid == 1) output_backward_ready = 1;
        @(posedge clock) #1 output_backward_ready = 0;
      end
      $display;
    end
    $finish(0);
  end

endmodule
