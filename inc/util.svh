`ifndef UTIL_INCLUDED
`define UTIL_INCLUDED

`include "dump.svh"
`include "random.svh"

function integer abs(integer val);
  abs = val < 0 ? -val : val;
endfunction : abs

`endif
