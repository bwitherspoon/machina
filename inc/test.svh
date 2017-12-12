`ifndef TEST_INCLUDED
`define TEST_INCLUDED

`define test_equal(lhs, rhs) \
  do if ((lhs) !== (rhs)) begin \
  `ifdef __ICARUS__ \
    $error("failed equality test: %s, %s = 'h%h, %s = 'h%h", "lhs == rhs`", `"lhs`", (lhs), `"rhs`", (rhs)); \
    $stop; \
  `else \
    $fatal("failed equality test: %s, %s = 'h%h, %s = 'h%h", "lhs == rhs`", `"lhs`", (lhs), `"rhs`", (rhs)); \
  `endif \
  end while (0)

`endif // TEST_INCLUDED
