module top;
  `define ARGW 8
  `define ARGD 2
  `define RESW 8
  `define ERRW 16
  `include "test.svh"

  perceptron #(.ARGD(ARGD)) uut(.*);

  logic [ARGN-1:0][ARGD-1:0][ARGW-1:0] arg [4];
  logic [RESD-1:0][RESW-1:0] tgt [4];
  logic [RESD-1:0][RESW-1:0] res;
  logic signed [ERRD-1:0][ERRW-1:0] err;
  logic [FBKD-1:0][FBKW-1:0] fbk;

  task and_test;
  begin
    arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
    tgt[0] = 8'h00; tgt[1] = 8'h00; tgt[2] = 8'h00; tgt[3] = 8'hff;
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
      `ASSERT_EQUAL(abs(err), 0);
    end
  end
  endtask

  initial begin
    dump;
    and_test;
    $finish;
  end
endmodule
