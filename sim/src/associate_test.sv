`include "debug.vh"

module associate_test;
  `define RES_WIDTH 16
  `include "test.svh"

  logic [ARG_DEPTH-1:0][ARG_WIDTH-1:0] arg [4];
  logic [RES_WIDTH-1:0] res;
  logic signed [RES_WIDTH-1:0] tgt [4];
  logic signed [RES_WIDTH-1:0] act;
  logic signed [ERR_WIDTH-1:0] err;
  logic [FBK_DEPTH-1:0][FBK_WIDTH-1:0] fbk;

  associate #(.ARGN(ARG_DEPTH), .RATE(1)) uut (.*);

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
      `ASSERT(abs(err) == 0);
    end
  end
  endtask : train

  task fwd_test;
  begin
    forward(16'h0000, res);
    `ASSERT(res == 16'b0);
  end
  endtask : fwd_test

  task bwd_test;
  begin
    en = 1;
    forward(16'h0000, res);
    `ASSERT(res == 16'b0);
    backward(16'h0000, fbk);
    `ASSERT(fbk == 32'b0);
  end
  endtask : bwd_test

  task and_test;
  begin
  // Logical AND function with linear threshold
  arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
  tgt[0] = 16'h0000; tgt[1] = 16'h0000; tgt[2] = 16'h0000; tgt[3] = 16'h00ff;
  train;
  end
  endtask : and_test

  task or_test;
  begin
  // Logical OR function with linear threshold
  arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
  tgt[0] = 16'h0000; tgt[1] = 16'h00ff; tgt[2] = 16'h00ff; tgt[3] = 16'h00ff;
  train;
  end
  endtask : or_test

  task test;
  begin
    fwd_test;
    bwd_test;
    reset;
    and_test;
    reset;
    or_test;
  end
  endtask : test

  integer seed = 32'hdeadbeef;
  task init;
  begin
    for (int n = 0; n < ARG_DEPTH; n++)
      uut.weights[n] = $random(seed) % 2**4;
  end
  endtask : init

  initial begin
    dump;
    init;
    test;
    $finish;
  end

endmodule
