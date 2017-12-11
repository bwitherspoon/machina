`ifndef SERIAL_INCLUDED
`define SERIAL_INCLUDED

`include "clock.svh"

parameter BAUDRATE = 96e2;

localparam CYCLES_PER_SYMBOL = $rtoi(FREQUENCY / BAUDRATE);

`define stx(prefix=) \
  logic prefix``rxd = 1; \
  task prefix``stx(input [7:0] dat); \
  begin \
    prefix``rxd = 0; \
    #(CYCLES_PER_SYMBOL*PERIOD); \
    for (int i = 0; i < 8; i++) begin \
      prefix``rxd = dat[i]; \
      #(CYCLES_PER_SYMBOL*PERIOD); \
    end \
    prefix``rxd = 1; \
    #(CYCLES_PER_SYMBOL*PERIOD); \
  end \
  endtask : prefix``stx

`define srx(prefix=) \
  logic prefix``txd; \
  task prefix``srx(output [7:0] dat); \
  begin \
    wait (prefix``txd == 0) #(1.5*CYCLES_PER_SYMBOL*PERIOD); \
    for (int i = 0; i < 8; i++) begin \
      dat[i] = prefix``txd; \
      #(CYCLES_PER_SYMBOL*PERIOD); \
    end \
    #(CYCLES_PER_SYMBOL*PERIOD); \
  end \
  endtask : prefix``srx

`endif // SERIAL_INCLUDED
