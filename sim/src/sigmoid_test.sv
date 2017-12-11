module testbench;
  `define ARGW 16
  `define RESW 8
  `define ERRW 16
  `include "test.svh"

  parameter funct = "sigmoid_funct.dat";
  parameter deriv = "sigmoid_deriv.dat";

  sigmoid #(funct, deriv) uut (.*);

  logic [RESW-1:0] res;
  logic [FBKW-1:0] fbk;

  task fwd;
  begin
    en = 0;
    forward(16'h0000, res);
    `ASSERT_EQUAL(res, 8'h80);
    forward(16'h07ff, res);
    `ASSERT_EQUAL(res, 8'hff);
    forward(16'hf800, res);
    `ASSERT_EQUAL(res, 8'h00);
  end
  endtask : fwd

  task bwd;
  begin
    en = 1;
    forward(0, res);
    `ASSERT_EQUAL(res, 8'h80);
    backward(256, fbk);
    `ASSERT_EQUAL(fbk, 16'h0040);
  end
  endtask : bwd

  task test;
  begin
    fwd;
    bwd;
  end
  endtask : test

  initial begin
    dump;
    test;
    reset;
    test;
    $finish;
  end

endmodule
