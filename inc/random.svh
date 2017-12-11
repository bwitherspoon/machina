`ifndef RANDOM_INCLUDED
`define RANDOM_INCLUDED

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

`endif
