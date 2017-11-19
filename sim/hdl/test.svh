task argument;
  input [15:0] data;
  begin
    argument_valid = 1;
    argument_data = data;
    wait (argument_ready) @ (posedge clock);
    #1 argument_valid = 0;
  end
endtask

task feedback;
  input [15:0] data;
  begin
    feedback_valid = 1;
    feedback_data = data;
    wait (feedback_ready) @ (posedge clock);
    #1 feedback_valid = 0;
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

task delta;
  output [15:0] data;
  begin
    wait (delta_valid) #1 delta_ready = 1;
    @ (posedge clock) data = delta_data;
    #1 delta_ready = 1;
  end
endtask
