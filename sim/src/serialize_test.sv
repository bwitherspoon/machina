module testbench;
  // `define ARGW 16
  // `define ARGN 4
  // `define RESW 18
  // `include "test.svh"
  //
  // serialize #(.ARGW(ARGW), .ARGN(ARGN)) uut (.*);
  //
  // task test;
  //   begin
  //     fork
  //       begin : arg_worker
  //         logic [ARGN-1:0][ARGD-1:0][ARGW-1:0] arg;
  //         bit arg_timeout = 0;
  //         // TODO iverilog 10 (not 11) seg faults with for loop local int
  //         int n;
  //         for (n = 0; n < ARGN; n++) begin : arg_loop
  //           arg[n] = n[ARGW-1:0];
  //         end : arg_loop
  //         argument(arg, arg_timeout);
  //         `ASSERT_EQUAL(arg_timeout, 0);
  //       end : arg_worker
  //       begin : res_worker
  //         logic [RESD-1:0][RESW-1:0] res;
  //         bit res_timeout;
  //         // TODO iverilog 10 (not 11) seg faults with for loop local int
  //         int n;
  //         for (n = 0; n < ARGN; n++) begin : res_loop
  //           res_timeout = 0;
  //           result(res, res_timeout);
  //           `ASSERT_EQUAL(res_timeout, 0);
  //           `ASSERT_EQUAL(res, ({n[$clog2(ARGN)-1:0], n[ARGW-1:0]}));
  //         end : res_loop
  //       end : res_worker
  //     join
  //   end
  // endtask

  initial begin
    $finish;
  end
endmodule
