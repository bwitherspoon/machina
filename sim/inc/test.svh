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
`ifndef RESK
`define RESK 1
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
localparam RESK = `RESK;
localparam ERRW = `ERRW;
localparam ERRD = `ERRD;
localparam FBKW = `FBKW;
localparam FBKD = `FBKD;

`undef ARGW
`undef ARGD
`undef ARGN
`undef RESW
`undef RESD
`undef RESK
`undef ERRW
`undef ERRD
`undef FBKW
`undef FBKD

logic clk = 0;
always #5 clk = ~clk;

logic rst = 0;
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
  input [ARGN-1:0][ARGD-1:0][ARGW-1:0] arg;
  output [RESK-1:0][RESD-1:0][RESW-1:0] res;
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
        for (int n = 0; n < ARGN; n++) begin
          arg_stb[n] = 1;
          arg_dat[n] = arg;
          wait (arg_rdy[n]) @(posedge clk);
          #1 arg_stb[n] = 0;
        end
      end
      begin
        for (int k = 0; k < RESK; k++) begin
          wait (res_stb) #1 res_rdy = 1;
          @(posedge clk) res[k] = res_dat;
          #1 res_rdy = 0;
        end
        disable forward_timeout;
      end
    join
  end
endtask

task backward;
  input [ERRW-1:0] err;
  output [FBKD-1:0][FBKW-1:0] fbk;
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
