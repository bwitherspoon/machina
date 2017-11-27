module associate_tb;
`define TESTBENCH_WIDTH 32
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
  logic [15:0] res_dat;

  logic err_stb = 0;
  logic err_rdy;
  logic [15:0] err_dat;

  logic fbk_stb;
  logic fbk_rdy = 0;
  logic [1:0][15:0] fbk_dat;

  logic [1:0][7:0] arg [4];
  logic [15:0] res;
  logic signed [15:0] tgt [4];
  logic signed [15:0] act;
  logic signed [15:0] err;
  logic [1:0][15:0] fbk;

  associate #(.N(2), .RATE(0), .SEED(0)) associator (.*);

  task train;
  begin
    en = 1;
    repeat (25) begin
      for (int i = 0; i < 4; i++) begin
        forward_pass(arg[i], res);
        act = ($signed(res) < 0) ? 16'h0000 : 16'h00ff;
        err = tgt[i] - act;
        backward_pass(err, fbk);
      end
    end
    en = 0;
    for (int i = 0; i < 4; i++) begin
      forward_pass(arg[i], res);
      act = ($signed(res) < 0) ? 16'h0000 : 16'h00ff;
      err = tgt[i] - act;
      `ifdef DEBUG
        $write("DEBUG: ");
        $write("%4.1f * %2.1f + ", associator.weight[1]/256.0, arg[i][1]/256.0);
        $write("%4.1f * %2.1f + ", associator.weight[0]/256.0, arg[i][0]/256.0);
        $write("%4.1f = %4.1f -> ", associator.bias/256.0, $signed(res)/256.0);
        $write("%2.1f ? %2.1f ! %4.1f\n", act/256.0, tgt[i]/256.0, err/256.0);
      `endif
    `TESTBENCH_ASSERT(abs(err) == 0);
    end
  end
  endtask : train

  initial begin
`ifdef DUMPFILE
    $dumpfile(`"`DUMPFILE`");
    $dumpvars;
`endif
    // Test 1 (initial)
    forward_pass(16'h0000, res);
    `TESTBENCH_ASSERT(res == 16'h0000);
    en = 1;
    forward_pass(16'h0000, res);
    `TESTBENCH_ASSERT(res == 16'h0000);
    backward_pass(16'h0000, fbk);
    `TESTBENCH_ASSERT(fbk == 16'h0000);
    // Test 2 (AND with linear threshold)
    arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
    tgt[0] = 16'h0000; tgt[1] = 16'h0000; tgt[2] = 16'h0000; tgt[3] = 16'h00ff;
    reset();
    train();
    // Test 3 (OR with linear threshold)
    tgt[0] = 16'h0000; tgt[1] = 16'h00ff; tgt[2] = 16'h00ff; tgt[3] = 16'h00ff;
    reset();
    train();
    // Success
    $finish;
  end

endmodule
