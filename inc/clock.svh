`ifndef CLOCK_INCLUDED
`define CLOCK_INCLUDED

`define clock(freq=100e6, unit=1e-9) \
  localparam PERIOD = 1 / (freq) / (unit); \
  logic clk; \
  initial begin : clock \
    clk <= 0; \
    forever #(PERIOD/2) clk = ~clk; \
  end : clock

`endif // CLOCK_INCLUDED
