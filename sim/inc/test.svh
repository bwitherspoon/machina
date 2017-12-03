`ifndef TEST_INCLUDED
`define TEST_INCLUDED

`ifndef TIMEOUT
`define TIMEOUT 1000000
`endif
localparam TIMEOUT = `TIMEOUT;
`undef TIMEOUT

`ifndef ARGW
`define ARGW 8
`endif
`ifndef ARGN
`define ARGN 1
`endif
`ifndef RESW
`define RESW `ARGW
`endif
`ifndef ERRW
`define ERRW `RESW
`endif
`ifndef FBKW
`define FBKW `ERRW
`endif
`ifndef FBKN
`define FBKN `ARGN
`endif

localparam ARGW = `ARGW;
localparam ARGN = `ARGN;
localparam RESW = `RESW;
localparam ERRW = `ERRW;
localparam FBKW = `FBKW;
localparam FBKN = `FBKN;

`undef ARGW
`undef ARGN
`undef RESW
`undef ERRW
`undef FBKW
`undef FBKN

logic clk = 0;
always #5 clk = ~clk;

logic rst = 0;
logic en = 0;

logic arg_stb = 0;
logic [ARGN-1:0][ARGW-1:0] arg_dat;
logic arg_rdy;

logic res_stb;
logic [RESW-1:0] res_dat;
logic res_rdy = 0;

logic err_stb = 0;
logic [ERRW-1:0] err_dat;
logic err_rdy;

logic fbk_stb;
logic [FBKN-1:0][FBKW-1:0] fbk_dat;
logic fbk_rdy = 0;

task dump;
  begin
    reg [128*8:1] dumpfile;
    if ($value$plusargs("dumpfile=%s", dumpfile)) begin
      $dumpfile(dumpfile);
      $dumpvars;
    end
  end
endtask

task reset;
  begin
    rst = 1;
    repeat (2) @ (posedge clk);
    #1 rst = 0;
  end
endtask

task forward;
  input [ARGN-1:0][ARGW-1:0] arg;
  output [RESW-1:0] res;
  begin
    fork
      begin : forward_timeout
        #TIMEOUT;
        $display("ERROR: [%0t] %s:%0d: forward pass timeout", $time, `__FILE__, `__LINE__);
        `ifndef FINISH
          $stop;
        `else
          $finish;
        `endif
      end
      begin
        arg_stb = 1;
        arg_dat = arg;
        wait (arg_rdy) @ (posedge clk);
        #1 arg_stb = 0;
      end
      begin
        wait (res_stb) #1 res_rdy = 1;
        @ (posedge clk) res = res_dat;
        #1 res_rdy = 0;
        disable forward_timeout;
      end
    join
  end
endtask

task backward;
  input [ERRW-1:0] err;
  output [FBKN-1:0][FBKW-1:0] fbk;
  begin
    fork
      begin : backward_timeout
        #TIMEOUT;
        $display("ERROR: [%0t] %s:%0d: backward pass timeout", $time, `__FILE__, `__LINE__);
        `ifndef FINISH
          $stop;
        `else
          $finish;
        `endif
      end
      begin
        err_stb = 1;
        err_dat = err;
        wait (err_rdy) @ (posedge clk);
        #1 err_stb = 0;
      end
      begin
        wait (fbk_stb) #1 fbk_rdy = 1;
        @ (posedge clk) fbk = fbk_dat;
        #1 fbk_rdy = 0;
        disable backward_timeout;
      end
    join
  end
endtask

function integer abs(integer val);
  abs = val < 0 ? -val : val;
endfunction

`endif
