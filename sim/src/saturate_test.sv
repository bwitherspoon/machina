module top;
  `define ARGW 24
  `define RESW 16
  `include "test.svh"

  saturate #(.ARGW(ARGW), .RESW(RESW)) uut (.*);

  logic [RESW-1:0] res;

  task test0;
    begin
      forward(24'h000ff, res);
      `ASSERT_EQUAL(res, 16'h00ff);
      forward(24'hffff00, res);
      `ASSERT_EQUAL(res, 16'hff00);
      forward(24'h7fffff, res);
      `ASSERT_EQUAL(res, 16'h7fff);
      forward(24'h800000, res);
      `ASSERT_EQUAL(res, 16'h8000);
end
  endtask

  initial begin
    dump;
    test0;
    reset;
    test0;
    $finish;
  end
endmodule
