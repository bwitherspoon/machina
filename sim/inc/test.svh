`ifndef TEST_INCLUDED
`define TEST_INCLUDED

`ifndef TIMEOUT
`define TIMEOUT 1000000
`endif
localparam TIMEOUT = `TIMEOUT;
`undef TIMEOUT

`ifndef ARG_WIDTH
`define ARG_WIDTH 8
`endif
`ifndef ARG_DEPTH
`define ARG_DEPTH 2
`endif
`ifndef RES_WIDTH
`define RES_WIDTH `ARG_WIDTH
`endif
`ifndef ERR_WIDTH
`define ERR_WIDTH 16
`endif
`ifndef FBK_WIDTH
`define FBK_WIDTH `ERR_WIDTH
`endif
`ifndef FBK_DEPTH
`define FBK_DEPTH `ARG_DEPTH
`endif

localparam ARG_WIDTH = `ARG_WIDTH;
localparam ARG_DEPTH = `ARG_DEPTH;
localparam RES_WIDTH = `RES_WIDTH;
localparam ERR_WIDTH = `ERR_WIDTH;
localparam FBK_WIDTH = `FBK_WIDTH;
localparam FBK_DEPTH = `FBK_DEPTH;

`undef ARG_WIDTH
`undef ARG_DEPTH
`undef RES_WIDTH
`undef ERR_WIDTH
`undef FBK_WIDTH
`undef FBK_DEPTH

logic clk = 0;
always #5 clk = ~clk;

logic rst = 0;
logic en = 0;

logic arg_stb = 0;
logic [ARG_DEPTH-1:0][ARG_WIDTH-1:0] arg_dat;
logic arg_rdy;

logic res_stb;
logic [RES_WIDTH-1:0] res_dat;
logic res_rdy = 0;

logic err_stb = 0;
logic [ERR_WIDTH-1:0] err_dat;
logic err_rdy;

logic fbk_stb;
logic [FBK_DEPTH-1:0][FBK_WIDTH-1:0] fbk_dat;
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
  input [ARG_DEPTH-1:0][ARG_WIDTH-1:0] arg;
  output [RES_WIDTH-1:0] res;
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
  input [ERR_WIDTH-1:0] err;
  output [FBK_DEPTH-1:0][FBK_WIDTH-1:0] fbk;
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
