`ifndef UTIL_INCLUDED
`define UTIL_INCLUDED

function int unsigned random(int unsigned max = 2**32);
  int seed = 0;
  return {$random(seed)} % max;
endfunction : random

task seed;
  if ($test$plusargs("seed") && !$value$plusargs("seed=%d", random.seed))
    $error("invalid seed");
  else
    $info("using seed %0d", random.seed);
endtask : seed

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
