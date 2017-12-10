task dump;
  begin
    string dumpfile;
    if ($value$plusargs("dumpfile=%s", dumpfile)) begin
      $dumpfile(dumpfile);
      $dumpvars;
    end
  end
endtask : dump

task reset;
  begin
    rst = 1;
    repeat (2) @ (posedge clk);
    #1 rst = 0;
  end
endtask : reset

function integer abs(integer val);
  abs = val < 0 ? -val : val;
endfunction : abs
