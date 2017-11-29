`include "debug.vh"

module sigmoid_tb;
  `define ARG_WIDTH 16
  `define ARG_DEPTH 1
  `define RES_WIDTH 8
  `include "test.svh"

  parameter ACTIV = "gen/dat/sigmoid_activ.dat";
  parameter DERIV = "gen/dat/sigmoid_deriv.dat";

  sigmoid #(ACTIV, DERIV) uut (.*);

  logic [RES_WIDTH-1:0] res;
  logic [FBK_WIDTH-1:0] fbk;

  task test0;
  begin
    en = 0;
    forward(16'h0000, res);
    `ASSERT(res == 8'h80);
    forward(16'h07ff, res);
    `ASSERT(res == 8'hff);
    forward(16'hf800, res);
    `ASSERT(res == 8'h00);
  end
  endtask : test0

  task test1;
  begin
    en = 1;
    forward(0, res);
    `ASSERT(res == 8'h80);
    backward(256, fbk);
    `ASSERT(fbk == 16'h0040);
  end
  endtask : test1

  initial begin
    dump;
    test0;
    reset;
    test1;
    $finish;
  end

endmodule
