module top;
  `define ARGW 16
  `define ARGN 4
  `define RESW 18
  `include "test.svh"

  serialize #(.ARGW(ARGW), .ARGN(ARGN)) uut (.*);

  task test;
    begin
      fork
        begin : argument_worker
          logic [ARGN-1:0][ARGD-1:0][ARGW-1:0] arg;
          bit timeout = 0;
          // TODO iverilog 10 (not 11) seg faults with for loop local int
          int n;
          for (n = 0; n < ARGN; n++) begin : argument_loop
            arg[n] = n[ARGW-1:0];
          end : argument_loop
          argument(arg, timeout);
          //`ASSERT_EQUAL(timeout, 0);
        end : argument_worker
        begin : result_worker
          logic [RESD-1:0][RESW-1:0] res;
          bit timeout;
          // TODO iverilog 10 (not 11) seg faults with for loop local int
          int n;
          for (n = 0; n < ARGN; n++) begin : result_loop
            timeout = 0;
            result(res, timeout);
            //`ASSERT_EQUAL(timeout, 0);
            `ASSERT_EQUAL(res, ({n[$clog2(ARGN)-1:0], n[ARGW-1:0]}));
          end : result_loop
        end : result_worker
      join
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
