module perceptron_test;
`include "test.svh"

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic argument_valid = 0;
  logic argument_ready;
  logic [1:0][7:0] argument_data;

  logic result_valid;
  logic result_ready = 0;
  logic [7:0] result_data;

  logic error_valid = 0;
  logic error_ready;
  logic [15:0] error_data;

  logic propagate_valid;
  logic propagate_ready = 0;
  logic [1:0][15:0] propagate_data;

  perceptron #(.N(2)) neuron (.*);

  logic [1:0][7:0] arg [4];
  logic [7:0] tgt [4];
  logic [7:0] res;
  logic signed [15:0] err;
  logic [1:0][15:0] prp;

  initial begin
`ifdef DUMPFILE
    $dumpfile(`"`DUMPFILE`");
    $dumpvars;
`endif
    // Test 1 (AND)
    arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
    tgt[0] = 8'h00; tgt[1] = 8'h00; tgt[2] = 8'h00; tgt[3] = 8'hff;
    err = 16'h7FFF;
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    train = 1;
    repeat (10) begin
      for (int i = 0; i < 4; i++) begin
        forward(arg[i], res);
        err = $signed({1'b0, tgt[i]}) - $signed({1'b0, res});
        backward(err, prp);
      end
    end
    train = 0;
    for (int i = 0; i < 4; i++) begin
      forward(arg[i], res);
      err = $signed({1'b0, tgt[i]}) - $signed({1'b0, res});
`ifdef DEBUG
      $write("DEBUG: ");
      $write("%4.1f * %1.0f + ", neuron.associate.weight[1]/256.0, arg[i][1]/256.0);
      $write("%4.1f * %1.0f + ", neuron.associate.weight[0]/256.0, arg[i][0]/256.0);
      $write("%4.1f = %1.0f ? ", neuron.associate.bias/256.0, res/256.0);
      $write("%1.0f ! %2.0f\n", tgt[i]/256.0, err/256.0);
`endif
      `TEST(abs(err) == 0);
    end
    // Success
    $finish;
  end
endmodule
