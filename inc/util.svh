`ifndef UTIL_INCLUDED
`define UTIL_INCLUDED

task dump;
  begin
    string dumpfile;
    if ($value$plusargs("dumpfile=%s", dumpfile)) begin
      $dumpfile(dumpfile);
      $dumpvars;
    end
  end
endtask : dump

function integer abs(integer val);
  abs = val < 0 ? -val : val;
endfunction : abs

`endif
