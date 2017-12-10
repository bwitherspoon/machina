`ifndef TEST_INCLUDED
`define TEST_INCLUDED

`include "debug.vh"
`include "util.svh"
`include "clock.svh"
`include "reset.svh"

`ifndef TIMEOUT
`define TIMEOUT 1000000
`endif
localparam TIMEOUT = `TIMEOUT;
`undef TIMEOUT

`ifndef ARGW
`define ARGW 8
`endif
`ifndef ARGD
`define ARGD 1
`endif
`ifndef ARGN
`define ARGN 1
`endif
`ifndef RESW
`define RESW `ARGW
`endif
`ifndef RESD
`define RESD 1
`endif
`ifndef ERRW
`define ERRW 16
`endif
`ifndef ERRD
`define ERRD 1
`endif
`ifndef FBKW
`define FBKW `ERRW
`endif
`ifndef FBKD
`define FBKD `ARGD
`endif

localparam ARGW = `ARGW;
localparam ARGD = `ARGD;
localparam ARGN = `ARGN;
localparam RESW = `RESW;
localparam RESD = `RESD;
localparam ERRW = `ERRW;
localparam ERRD = `ERRD;
localparam FBKW = `FBKW;
localparam FBKD = `FBKD;

`undef ARGW
`undef ARGD
`undef ARGN
`undef RESW
`undef RESD
`undef ERRW
`undef ERRD
`undef FBKW
`undef FBKD

logic en = 0;

logic [ARGN-1:0] arg_stb = 0;
logic [ARGN-1:0][ARGD-1:0][ARGW-1:0] arg_dat;
logic [ARGN-1:0] arg_rdy;

logic res_stb;
logic [RESD-1:0][RESW-1:0] res_dat;
logic res_rdy = 0;

logic err_stb = 0;
logic [ERRD-1:0][ERRW-1:0] err_dat;
logic err_rdy;

logic fbk_stb;
logic [FBKD-1:0][FBKW-1:0] fbk_dat;
logic fbk_rdy = 0;

task argument;
  input [ARGN-1:0][ARGD-1:0][ARGW-1:0] arg;
  output ret;
  begin
    fork
      begin : timeout
        ret = 0;
        #TIMEOUT disable worker;
        ret = 1;
        `DEBUG("argument timeout");
      end : timeout
      begin : worker
        // TODO iverilog 10 (not 11) seg faults with for loop local int
        int n;
        for (n = 0; n < ARGN; n++) begin : loop
          arg_stb[n] = 1;
          arg_dat[n] = arg[n];
          wait (arg_rdy[n]) @(posedge clk);
          #1 arg_stb[n] = 0;
        end : loop
        disable timeout;
      end : worker
    join
  end
endtask: argument

task result;
  output [RESD-1:0][RESW-1:0] res;
  output ret;
  begin
    fork
      begin : timeout
        ret = 0;
        #TIMEOUT disable worker;
        ret = 1;
        `DEBUG("result timeout");
      end : timeout
      begin : worker
        wait (res_stb) res_rdy = 1;
        @(posedge clk) `ASSERT_EQUAL(res_stb, 1);
        res = res_dat;
        #1 res_rdy = 0;
        disable timeout;
      end : worker
    join
  end
endtask : result

task forward;
  input [ARGN-1:0][ARGD-1:0][ARGW-1:0] arg;
  output [RESD-1:0][RESW-1:0] res;
  begin
    fork
      begin
        bit timeout = 0;
        argument(arg, timeout);
        `ASSERT_EQUAL(timeout, 0);
      end
      begin
        bit timeout = 0;
        result(res, timeout);
        `ASSERT_EQUAL(timeout, 0);
      end
    join
  end
endtask : forward

task backward;
  input [ERRW-1:0] err;
  output [FBKD-1:0][FBKW-1:0] fbk;
  begin
    fork
      begin : timeout
        #TIMEOUT;
        $display("ERROR: [%0t] %s:%0d: backward pass timeout", $time, `__FILE__, `__LINE__);
        `ifndef FINISH
          $stop;
        `else
          $finish;
        `endif
      end : timeout
      begin : error
        err_stb = 1;
        err_dat = err;
        wait (err_rdy) @ (posedge clk);
        #1 err_stb = 0;
      end : error
      begin : feedback
        wait (fbk_stb) #1 fbk_rdy = 1;
        @ (posedge clk) fbk = fbk_dat;
        #1 fbk_rdy = 0;
        disable timeout;
      end : feedback
    join
  end
endtask : backward

`endif
