`ifndef UTILITY_INCLUDED
`define UTILITY_INCLUDED

function integer abs(integer val);
  abs = val < 0 ? -val : val;
endfunction : abs

`endif // UTILITY_INCLUDED
