`ifndef CHECK_INCLUDED
`define CHECK_INCLUDED

`define check_equal(lhs, rhs) \
  do if ((lhs) !== (rhs)) begin \
  `ifdef __ICARUS__ \
    $error("failed equality check: %s, %s = 'h%h, %s = 'h%h", `"lhs == rhs`", `"lhs`", (lhs), `"rhs`", (rhs)); \
    $stop; \
  `else \
    $fatal(0, "failed equality check: %s, %s = 'h%h, %s = 'h%h", "lhs == rhs`", `"lhs`", (lhs), `"rhs`", (rhs)); \
  `endif \
  end while (0)

`endif // check_INCLUDED
