`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
`include "reset.svh"
`include "test.svh"

module testbench #(
  parameter funct = "sigmoid_funct.dat",
  parameter deriv = "sigmoid_deriv.dat"
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam FREQ = 100e6;
  localparam ARGW = 16;
  localparam RESW = 8;
  localparam ERRW = 16;
  localparam FBKW = ERRW;

  `clock(FREQ)
  `reset
  `master(arg_, ARGW)
  `slave(res_, RESW)
  `master(err_, ERRW)
  `slave(fbk_, FBKW)

  logic en;
  logic [RESW-1:0] res;
  logic [FBKW-1:0] fbk;

  sigmoid #(funct, deriv) uut (.*);

  task fwd;
    logic [ARGW-1:0] arg [3];
    logic [RESW-1:0] exp [3];
    logic [RESW-1:0] res;
    begin
      arg[0] = 16'h0000; arg[1] = 16'h07ff; arg[2] = 16'hf800;
      exp[0] = 8'h80;    exp[1] = 8'hff;    exp[2] = 8'h00;
      en = 0;
      for (int i = 0; i < 3; i++) begin
        fork
          arg_xmt(arg[i]);
          res_rcv(res);
        join
        `test_equal(res, exp[i]);
      end
    end
  endtask : fwd

  task bwd;
    logic [RESW-1:0] res;
    logic [FBKW-1:0] fbk;
    begin
      en = 1;
      fork
        arg_xmt(16'h0000);
        res_rcv(res);
        err_xmt(16'd256);
        fbk_rcv(fbk);
      join
      `test_equal(res, 8'h80);
      `test_equal(fbk, 16'h0040);
      en = 0;
    end
  endtask : bwd

  task test;
  fork
    begin : timeout
      repeat (1e6) @(posedge clk);
      disable worker;
      `ifdef __ICARUS__
        $error("testbench timeout");
        $stop;
      `else
        $fatal(0, "testbench timeout");
      `endif
    end : timeout
    begin : worker
      fwd;
      bwd;
      disable timeout;
    end : worker
  join
  endtask : test

  initial begin
    dump;
    test;
    reset;
    test;
    $finish;
  end

endmodule
