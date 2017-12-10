`ifndef CLOCK_INCLUDED
`define CLOCK_INCLUDED

parameter FREQUENCY = 12e6;
parameter TIMEUNIT = 1e-9;

localparam PERIOD = 1 / FREQUENCY / TIMEUNIT;

logic clk = 0;

always #(PERIOD/2) clk <= ~clk;

`endif // CLOCK_INCLUDED
