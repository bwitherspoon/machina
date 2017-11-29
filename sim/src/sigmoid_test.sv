`include "debug.vh"

module sigmoid_test;
  `define ARG_WIDTH 16
  `define ARG_DEPTH 1
  `define RES_WIDTH 8
  `include "test.svh"

  parameter activ = "sigmoid_activ.dat";
  parameter deriv = "sigmoid_deriv.dat";

  sigmoid #(activ, deriv) uut (.*);

  logic [RES_WIDTH-1:0] res;
  logic [FBK_WIDTH-1:0] fbk;

  task fwd_test;
  begin
    en = 0;
    forward(16'h0000, res);
    `ASSERT(res == 8'h80);
    forward(16'h07ff, res);
    `ASSERT(res == 8'hff);
    forward(16'hf800, res);
    `ASSERT(res == 8'h00);
  end
  endtask : fwd_test

  task bwd_test;
  begin
    en = 1;
    forward(0, res);
    `ASSERT(res == 8'h80);
    backward(256, fbk);
    `ASSERT(fbk == 16'h0040);
  end
  endtask : bwd_test

  initial begin
    dump;
    fwd_test;
    reset;
    bwd_test;
    $finish;
  end

endmodule
