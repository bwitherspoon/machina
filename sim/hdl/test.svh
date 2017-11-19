task argument;
  input [15:0] data;
  begin
    argument_valid = 1;
    argument_data = data;
    wait (argument_ready) @ (posedge clock);
    #1 argument_valid = 0;
  end
endtask

task result;
  output [15:0] data;
  begin
    wait (result_valid) #1 result_ready = 1;
    @ (posedge clock) data = result_data;
    #1 result_ready = 1;
  end
endtask

task error;
  input [15:0] data;
  begin
    error_valid = 1;
    error_data = data;
    wait (error_ready) @ (posedge clock);
    #1 error_valid = 0;
  end
endtask

task propagate;
  output [15:0] data;
  begin
    wait (propagate_valid) #1 propagate_ready = 1;
    @ (posedge clock) data = propagate_data;
    #1 propagate_ready = 1;
  end
endtask
