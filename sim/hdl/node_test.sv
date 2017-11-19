module node_test;
`define TEST_WIDTH 32
`include "test.svh"

  function logic [15:0] abs(logic [15:0] val);
    return (val[15]) ? -val : val;
  endfunction

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic argument_valid = 0;
  logic argument_ready;
  logic [1:0][7:0] argument_data;

  logic result_valid;
  logic result_ready = 0;
  logic [15:0] result_data;

  logic error_valid = 0;
  logic error_ready;
  logic [15:0] error_data;

  logic propagate_valid;
  logic propagate_ready = 0;
  logic [1:0][15:0] propagate_data;

  logic [1:0][7:0] arg [4];
  logic [15:0] tgt [4];
  logic [15:0] res;
  logic signed [15:0] err;
  logic [1:0][15:0] prp;

  node #(.N(2), .S(2), .SEED(0)) dut (
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
    forward(16'h7f7f, res);
    if (res != 16'hfff9) begin
      $display("ERROR: result invalid: %h", res);
      $stop;
    end
    train = 1;
    forward(16'hffff, res);
    if (res != 16'hfff4) begin
      $display("ERROR: result invalid: %h", res);
      $stop;
    end

    backward(16'h0000, prp);
    if (prp != 16'h00) begin
      $display("ERROR: propagation invalid: %h", prp);
      $stop;
    end
    // Test 2
    // FIXME Use array assignment patterns when supported
    arg[0] = 16'h0000;
    arg[1] = 16'h00ff;
    arg[2] = 16'hff00;
    arg[3] = 16'hffff;
    tgt[0] = 16'hff00;
    tgt[1] = 16'h007f;
    tgt[2] = 16'hff00;
    tgt[3] = 16'h007f;
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    // Train
    repeat (25) begin
      for (int i = 0; i < 4; i++) begin
        forward(arg[i], res);
        err = $signed(tgt[i]) - $signed(res);
        backward(err, prp);
      end
    end
    // Validate
    for (int i = 0; i < 4; i++) begin
      forward(arg[i], res);
      err = $signed(tgt[i]) - $signed(res);
`ifdef DEBUG
      $write("DEBUG: ");
      $write("%6.3f * %6.3f + ", dut.weight[1] / 256.0, arg[i][1] / 256.0);
      $write("%6.3f * %6.3f + ", dut.weight[0] / 256.0, arg[i][0] / 256.0);
      $write("%6.3f = %6.3f ? ", dut.bias / 256.0, $signed(res) / 256.0);
      $write("%6.3f ! %6.3f\n", $signed(tgt[i]) / 256.0, $signed(err) / 256.0);
`endif
      if (abs(err) > 4) begin
        $display("ERROR: error out of range: %6.3f", err / 256.0);
        $stop;
      end
      backward(err, prp);
    end
    // Success
    $finish;
  end

endmodule
