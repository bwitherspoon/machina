`ifndef SERIAL_INCLUDED
`define SERIAL_INCLUDED

`define serial(baud=96e2, unit=1e-9, prefix=) \
  logic prefix``rxd = 1; \
  logic prefix``txd; \
  task prefix``stx(input [7:0] d); \
  begin \
    prefix``rxd = 0; \
    #(1.0/(1.0*(baud))/(1.0*(unit))); \
    for (int i = 0; i < 8; i++) begin \
      prefix``rxd = d[i]; \
      #(1.0/(1.0*(baud))/(1.0*(unit))); \
      end \
    prefix``rxd = 1; \
    #(1.0/(1.0*(baud))/(1.0*(unit))); \
  end \
  endtask : prefix``stx \
  task prefix``srx(output [7:0] d); \
  begin \
    wait (prefix``txd == 0) #(1.5/(1.0*(baud))/(1.0*(unit))); \
    for (int i = 0; i < 8; i++) begin \
      d[i] = prefix``txd; \
      #(1.0/(1.0*(baud))/(1.0*(unit))); \
    end \
    #(1.0/(1.0*(baud))/(1.0*(unit))); \
  end \
  endtask : prefix``srx

`endif // SERIAL_INCLUDED
