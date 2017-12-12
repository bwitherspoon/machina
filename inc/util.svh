`ifndef UTIL_INCLUDED
`define UTIL_INCLUDED

function integer abs(integer val);
  abs = val < 0 ? -val : val;
endfunction : abs

`endif // UTIL_INCLUDED
