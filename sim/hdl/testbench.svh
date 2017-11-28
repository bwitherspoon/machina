`ifndef TESTBENCH_INCLUDED
`define TESTBENCH_INCLUDED

// $write("DEBUG:\nDEBUG: Dumping memory:\nDEBUG:\nDEBUG:");
// for (int i = 0; i < 4096; i++) begin
//   if (i != 0 && i % 8 == 0)
//     $write("\nDEBUG:");
//   $write("%3h", uut.deriv.mem[i]);
// end
// $write("\n");

`include "debug.vh"

`ifndef TESTBENCH_TIMEOUT
`define TESTBENCH_TIMEOUT 1000000
`endif

`ifndef TESTBENCH_WIDTH
`define TESTBENCH_WIDTH 16
`endif

function logic [`TESTBENCH_WIDTH-1:0] abs(logic signed [`TESTBENCH_WIDTH-1:0] val);
  return (val < 0) ? -val : val;
endfunction

task dumpargs;
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
  input [`TESTBENCH_WIDTH-1:0] arg;
  output [`TESTBENCH_WIDTH-1:0] res;
  begin
    fork
      begin : testbench_forward_timeout
        #`TESTBENCH_TIMEOUT $display("ERROR: %s:%0d: testbench forward pass timeout: %0t-%0t", `__FILE__, `__LINE__, $time - `TESTBENCH_TIMEOUT, $time);
        $stop;
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
        disable testbench_forward_timeout;
      end
    join
  end
endtask

task backward;
  input [`TESTBENCH_WIDTH-1:0] err;
  output [`TESTBENCH_WIDTH-1:0] fbk;
  begin
    fork
      begin : testbench_backward_timeout
        #`TESTBENCH_TIMEOUT $display("ERROR: %s:%0d: testbench backward pass timeout: %0t-%0t", `__FILE__, `__LINE__, $time - `TESTBENCH_TIMEOUT, $time);
        $stop;
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
        disable testbench_backward_timeout;
      end
    join
  end
endtask

`undef TESTBENCH_TIMEOUT
`undef TESTBENCH_WIDTH

`endif
