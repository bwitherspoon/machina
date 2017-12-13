`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "reset.svh"
`include "test.svh"
`include "util.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam ARGW = 8;
  localparam ARGD = 2;
  localparam RESW = 8;
  localparam ERRW = 16;
  localparam FBKW = 16;
  localparam FBKD = 2;

  `clock()
  `reset
  `master(arg_, ARGW, ARGD)
  `slave(res_, RESW)
  `master(err_, ERRW)
  `slave(fbk_, FBKW, FBKD)

  logic en = 0;

  perceptron #(.ARGD(ARGD)) uut(.*);

  task testcase;
    logic [ARGD-1:0][ARGW-1:0] arg [4];
    logic [RESW-1:0] tgt [4];
    logic [RESW-1:0] res;
    logic signed [ERRW-1:0] err;
    logic [FBKD-1:0][FBKW-1:0] fbk;
    begin
      // Logical AND function
      arg[0] = 16'h0000; arg[1] = 16'h00ff; arg[2] = 16'hff00; arg[3] = 16'hffff;
      tgt[0] = 8'h00; tgt[1] = 8'h00; tgt[2] = 8'h00; tgt[3] = 8'hff;
      reset;
      en = 1;
      repeat (10) begin
        for (int i = 0; i < 4; i++) begin
          arg_xmt(arg[i]);
          res_rcv(res);
          err = $signed({1'b0, tgt[i]}) - $signed({1'b0, res});
          err_xmt(err);
          fbk_rcv(fbk);
        end
      end
      en = 0;
      for (int i = 0; i < 4; i++) begin
        arg_xmt(arg[i]);
        res_rcv(res);
        err = $signed({1'b0, tgt[i]}) - $signed({1'b0, res});
        `test_equal(abs(err), 0);
      end
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
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
