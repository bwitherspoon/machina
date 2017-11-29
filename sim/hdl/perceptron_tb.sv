`include "debug.vh"

module perceptron_tb;
  `include "test.svh"

  perceptron #(.N(2)) uut(.*);

  logic [ARG_DEPTH-1:0][ARG_WIDTH-1:0] arg [4];
  logic [RES_WIDTH-1:0] tgt [4];
  logic [RES_WIDTH-1:0] res;
  logic signed [ERR_WIDTH-1:0] err;
  logic [FBK_DEPTH-1:0][FBK_WIDTH-1:0] fbk;

  initial begin
    dump;
    // Test 1 (AND)
    arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
    tgt[0] = 8'h00; tgt[1] = 8'h00; tgt[2] = 8'h00; tgt[3] = 8'hff;
    err = 16'h7FFF;
    reset;
    en = 1;
    repeat (10) begin
      for (int i = 0; i < 4; i++) begin
        forward(arg[i], res);
        err = $signed({1'b0, tgt[i]}) - $signed({1'b0, res});
        backward(err, fbk);
      end
    end
    en = 0;
    for (int i = 0; i < 4; i++) begin
      forward(arg[i], res);
      err = $signed({1'b0, tgt[i]}) - $signed({1'b0, res});
`ifndef NDEBUG
      $write("DEBUG: ");
      $write("%4.1f * %1.0f + ", uut.associator.weight[1]/256.0, arg[i][1]/256.0);
      $write("%4.1f * %1.0f + ", uut.associator.weight[0]/256.0, arg[i][0]/256.0);
      $write("%4.1f = %1.0f ? ", uut.associator.bias/256.0, res/256.0);
      $write("%1.0f ! %2.0f\n", tgt[i]/256.0, err/256.0);
`endif
      `ASSERT(abs(err) === 0);
    end
    // Success
    $finish;
  end
endmodule
