module top;
  `define ARGW 24
  `define RESW 40
  `include "test.svh"

  accumulate #(.ARGW(ARGW), .RESW(RESW)) uut (.*);

  logic [ARGW-1:0] arg [4];
  logic [RESW-1:0] exp [2];
  logic [RESW-1:0] res;

  task test;
    bit timeout = 0;
    begin
      arg[0] = 24'h0000ff; arg[1] = 24'h000001;
      arg[2] = 24'hffffff; arg[3] = 24'h00000f;
      exp[0] = 40'h00000000ff; exp[1] = 40'h000000000f;
      for (int i = 0; i < 3; i++) begin
        argument(arg[i], timeout);
        `ASSERT_EQUAL(timeout, 0);
      end

    end
  endtask

  initial begin
    dump;
    test;
    reset;
    test;
    $finish;
  end
endmodule
