`ifndef TEST_INCLUDED
`define TEST_INCLUDED

`ifndef TEST_WIDTH
`define TEST_WIDTH 16
`endif

`ifndef SYNTHESIS
  `define TEST(exp, msg="failed test") \
    do begin \
      if (!(exp)) begin \
        $display("ERROR: %s:%0d: %s: %s", `__FILE__, `__LINE__, msg, `"exp`"); \
        $stop; \
      end \
    end while (0)
`else
  `define TEST(exp) do while (0)
`endif

function logic [`TEST_WIDTH-1:0] abs(logic signed [`TEST_WIDTH-1:0] val);
  return (val < 0) ? -val : val;
endfunction

task test;
  input exp;
  if (!exp) begin
    $display("ERROR: ", `__FILE__, ": failed test");
    $stop;
  end
endtask

task argument;
  input [`TEST_WIDTH-1:0] data;
  begin
    argument_valid = 1;
    argument_data = data;
    wait (argument_ready) @ (posedge clock);
    #1 argument_valid = 0;
  end
endtask

task result;
  output [`TEST_WIDTH-1:0] data;
  begin
    wait (result_valid) #1 result_ready = 1;
    @ (posedge clock) data = result_data;
    #1 result_ready = 0;
  end
endtask

task error;
  input [`TEST_WIDTH-1:0] data;
  begin
    error_valid = 1;
    error_data = data;
    wait (error_ready) @ (posedge clock);
    #1 error_valid = 0;
  end
endtask

task propagate;
  output [`TEST_WIDTH-1:0] data;
  begin
    wait (propagate_valid) #1 propagate_ready = 1;
    @ (posedge clock) data = propagate_data;
    #1 propagate_ready = 0;
  end
endtask

task forward;
  input [`TEST_WIDTH-1:0] arg;
  output [`TEST_WIDTH-1:0] res;
  begin
    argument(arg);
    result(res);
  end
endtask

task backward;
  input [`TEST_WIDTH-1:0] err;
  output [`TEST_WIDTH-1:0] prp;
  begin
    error(err);
    propagate(prp);
  end
endtask

`undef TEST_WIDTH

`endif
