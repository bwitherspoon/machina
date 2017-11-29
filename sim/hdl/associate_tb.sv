`include "debug.vh"

module associate_tb;
  `define RES_WIDTH 16
  `include "test.svh"

  logic [ARG_DEPTH-1:0][ARG_WIDTH-1:0] arg [4];
  logic [RES_WIDTH-1:0] res;
  logic signed [RES_WIDTH-1:0] tgt [4];
  logic signed [RES_WIDTH-1:0] act;
  logic signed [ERR_WIDTH-1:0] err;
  logic [FBK_DEPTH-1:0][FBK_WIDTH-1:0] fbk;

  associate #(.N(2), .RATE(0), .SEED(0)) uut (.*);

  task train;
  begin
    en = 1;
    repeat (25) begin
      for (int i = 0; i < 4; i++) begin
        forward(arg[i], res);
        act = ($signed(res) < 0) ? 16'h0000 : 16'h00ff;
        err = tgt[i] - act;
        backward(err, fbk);
      end
    end
    en = 0;
    for (int i = 0; i < 4; i++) begin
      forward(arg[i], res);
      act = ($signed(res) < 0) ? 16'h0000 : 16'h00ff;
      err = tgt[i] - act;
      `ifndef NDEBUG
        $write("DEBUG: ");
        $write("%4.1f * %2.1f + ", uut.weight[1]/256.0, arg[i][1]/256.0);
        $write("%4.1f * %2.1f + ", uut.weight[0]/256.0, arg[i][0]/256.0);
        $write("%4.1f = %4.1f -> ", uut.bias/256.0, $signed(res)/256.0);
        $write("%2.1f ? %2.1f ! %4.1f\n", act/256.0, tgt[i]/256.0, err/256.0);
      `endif
    `ASSERT(abs(err) == 0);
    end
  end
  endtask : train

  task test0;
  begin
    forward(16'h0000, res);
    `ASSERT(res == 16'b0);
  end
  endtask : test0

  task test1;
  begin
    en = 1;
    forward(16'h0000, res);
    `ASSERT(res == 16'b0);
    backward(16'h0000, fbk);
    `ASSERT(fbk == 32'b0);
  end
  endtask : test1

  task test2;
  begin
  // Logical AND function with linear threshold
  arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
  tgt[0] = 16'h0000; tgt[1] = 16'h0000; tgt[2] = 16'h0000; tgt[3] = 16'h00ff;
  train;
  end
  endtask : test2

  task test3;
  begin
  // Logical OR function with linear threshold
  arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
  tgt[0] = 16'h0000; tgt[1] = 16'h00ff; tgt[2] = 16'h00ff; tgt[3] = 16'h00ff;
  train;
  end
  endtask : test3

  initial begin
    dump;
    test0;
    test1;
    reset;
    test2;
    reset;
    test3;
    // Success
    $finish;
  end

endmodule
