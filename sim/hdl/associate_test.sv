module associate_test;
`define TEST_WIDTH 32
`include "test.svh"

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic arg_valid = 0;
  logic arg_ready;
  logic [1:0][7:0] arg_data;

  logic res_valid;
  logic res_ready = 0;
  logic [15:0] res_data;

  logic err_valid = 0;
  logic err_ready;
  logic [15:0] err_data;

  logic fbk_valid;
  logic fbk_ready = 0;
  logic [1:0][15:0] fbk_data;

  logic [1:0][7:0] arg [4];
  logic [15:0] res;
  logic signed [15:0] tgt [4];
  logic signed [15:0] act;
  logic signed [15:0] err;
  logic [1:0][15:0] fbk;

  associate #(.N(2), .RATE(0), .SEED(0)) associator (.*);

  task trainer;
  begin
    train = 1;
    repeat (25) begin
      for (int i = 0; i < 4; i++) begin
        forward(arg[i], res);
        act = ($signed(res) < 0) ? 16'h0000 : 16'h00ff;
        err = tgt[i] - act;
        backward(err, fbk);
      end
    end
    train = 0;
    for (int i = 0; i < 4; i++) begin
      forward(arg[i], res);
      act = ($signed(res) < 0) ? 16'h0000 : 16'h00ff;
      err = tgt[i] - act;
      `ifdef DEBUG
        $write("DEBUG: ");
        $write("%4.1f * %2.1f + ", associator.weight[1]/256.0, arg[i][1]/256.0);
        $write("%4.1f * %2.1f + ", associator.weight[0]/256.0, arg[i][0]/256.0);
        $write("%4.1f = %4.1f -> ", associator.bias/256.0, $signed(res)/256.0);
        $write("%2.1f ? %2.1f ! %4.1f\n", act/256.0, tgt[i]/256.0, err/256.0);
      `endif
    `TEST(abs(err) == 0);
    end
  end
  endtask : trainer

  initial begin
`ifdef DUMPFILE
    $dumpfile(`"`DUMPFILE`");
    $dumpvars;
`endif
    // Test 1 (initial)
    forward(16'h0000, res);
    `TEST(res == 16'h0000);
    train = 1;
    forward(16'h0000, res);
    `TEST(res == 16'h0000);
    backward(16'h0000, fbk);
    `TEST(fbk == 16'h0000);
    // Test 2 (AND with linear threshold)
    arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
    tgt[0] = 16'h0000; tgt[1] = 16'h0000; tgt[2] = 16'h0000; tgt[3] = 16'h00ff;
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    trainer;
    // Test 3 (OR with linear threshold)
    tgt[0] = 16'h0000; tgt[1] = 16'h00ff; tgt[2] = 16'h00ff; tgt[3] = 16'h00ff;
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;
    trainer;
    // Success
    $finish;
  end

endmodule
