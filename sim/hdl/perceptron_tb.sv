module perceptron_tb;
`include "testbench.svh"

  bit clk = 0;
  always #5 clk = ~clk;

  bit rst = 0;
  bit en = 0;

  logic arg_stb = 0;
  logic arg_rdy;
  logic [1:0][7:0] arg_dat;

  logic res_stb;
  logic res_rdy = 0;
  logic [7:0] res_dat;

  logic err_stb = 0;
  logic err_rdy;
  logic [15:0] err_dat;

  logic fbk_stb;
  logic fbk_rdy = 0;
  logic [1:0][15:0] fbk_dat;

  perceptron #(.N(2)) uut(.*);

  logic [1:0][7:0] arg [4];
  logic [7:0] tgt [4];
  logic [7:0] res;
  logic signed [15:0] err;
  logic [1:0][15:0] fbk;

  initial begin
    dumpargs;
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
`ifdef DEBUG
      $write("DEBUG: ");
      $write("%4.1f * %1.0f + ", uut.associator.weight[1]/256.0, arg[i][1]/256.0);
      $write("%4.1f * %1.0f + ", uut.associator.weight[0]/256.0, arg[i][0]/256.0);
      $write("%4.1f = %1.0f ? ", uut.associator.bias/256.0, res/256.0);
      $write("%1.0f ! %2.0f\n", tgt[i]/256.0, err/256.0);
`endif
      `TESTBENCH_ASSERT(abs(err) === 0);
    end
    // Success
    $finish;
  end
endmodule
