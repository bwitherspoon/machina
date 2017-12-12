`include "debug.vh"
`include "interface.svh"
`include "random.svh"

module testbench #(
  parameter ARGW = 16
);
  `include "clock.svh"
  `include "dump.svh"
  `include "reset.svh"

  localparam RESW = 2*ARGW;

  `xmt(arg_, ARGW, 2)
  `rcv(res_, RESW)

  multiply #(ARGW) uut (.*);

  task testcase;
    logic signed [1:0][ARGW-1:0] arg;
    logic signed [1:0][RESW-1:0] res;
    repeat (8) begin
      arg[0] = random(2**16-1);
      arg[1] = random(2**16-1);
      res[0] = arg[0] * arg[1];
      arg_xmt(arg);
      res_rcv(res[1]);
      `ASSERT_EQUAL(res[0], res[1]);
    end
  endtask

  task test;
    fork
      begin : timeout
        repeat (1e6) @(posedge clk);
        disable worker;
        $error("testbench timeout");
        $stop;
      end : timeout
      begin : worker
        testcase;
        disable timeout;
      end : worker
    join
  endtask

  initial begin
    dump;
    seed;
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
