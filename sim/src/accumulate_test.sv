module testbench;
  // `define ARGW 24
  // `define RESW 40
  // `include "test.svh"
  //
  // accumulate #(.ARGW(ARGW), .RESW(RESW)) uut (.*);
  //
  // task test;
  //   begin
  //     fork
  //       begin
  //         logic [ARGW-1:0] arg [4];
  //         bit timeout;
  //         int i;
  //         arg[0] = 24'h0000ff; arg[1] = 24'h000001;
  //         arg[2] = 24'hffffff; arg[3] = 24'h00000f;
  //         for (i = 0; i < 3; i++) begin
  //           timeout = 0;
  //           argument(arg[i], timeout);
  //           `ASSERT_EQUAL(timeout, 0);
  //         end
  //         timeout = 0;
  //         repeat (2) @(posedge clk);
  //         @(negedge clk) argument(arg[3], timeout);
  //         `ASSERT_EQUAL(timeout, 0);
  //       end
  //       begin
  //         logic [RESW-1:0] res;
  //         bit timeout = 0;
  //         result(res, timeout);
  //         `ASSERT_EQUAL(timeout, 0);
  //         `ASSERT_EQUAL(res, 40'h00000000ff);
  //         timeout = 0;
  //         result(res, timeout);
  //         `ASSERT_EQUAL(timeout, 0);
  //         `ASSERT_EQUAL(res, 40'h000000000f);
  //       end
  //     join
  //   end
  // endtask

  initial begin
    // dump;
    // test;
    // reset;
    // test;
    $finish;
  end
endmodule
