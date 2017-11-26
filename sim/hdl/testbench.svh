`ifndef TESTBENCH_INCLUDED
`define TESTBENCH_INCLUDED

`ifndef TESTBENCH_WIDTH
`define TESTBENCH_WIDTH 16
`endif

`ifndef SYNTHESIS
  `define TESTBENCH_ASSERT(expr, msg="failed testbench assertion") \
    do begin \
      if (!(expr)) begin \
        $display("ERROR: %s:%0d: %s: %s", `__FILE__, `__LINE__, msg, `"expr`"); \
        $stop; \
      end \
    end while (0)
`else
  `define TESTBENCH_ASSERT(expr) do while (0)
`endif

function logic [`TESTBENCH_WIDTH-1:0] abs(logic signed [`TESTBENCH_WIDTH-1:0] val);
  return (val < 0) ? -val : val;
endfunction

task reset;
  begin
    rst = 1;
    repeat (2) @ (posedge clk);
    #1 rst = 0;
  end
endtask

task forward_pass;
  input [`TESTBENCH_WIDTH-1:0] arg;
  output [`TESTBENCH_WIDTH-1:0] res;
  begin
    fork
      begin : testbench_forward_pass_timeout
        #1000000 $display("ERROR: %s:%0d: testbench forward pass timeout: %0t", `__FILE__, `__LINE__, $time);
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
        disable testbench_forward_pass_timeout;
      end
    join
  end
endtask

task backward_pass;
  input [`TESTBENCH_WIDTH-1:0] err;
  output [`TESTBENCH_WIDTH-1:0] fbk;
  begin
    fork
      begin : testbench_backward_pass_timeout
        #1000000 $display("ERROR: %s:%0d: testbench backward pass timeout: %0t", `__FILE__, `__LINE__, $time);
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
        disable testbench_backward_pass_timeout;
      end
    join
  end
endtask

`undef TESTBENCH_WIDTH

`endif // TESTBENCH_INCLUDED
