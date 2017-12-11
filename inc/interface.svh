`ifndef INTERFACE_INCLUDED
`define INTERFACE_INCLUDED

`define rcv(prefix=) \
  logic prefix``stb; \
  logic [7:0] prefix``dat; \
  logic prefix``rdy = 0; \
  task prefix``rcv(output [7:0] d); \
  begin \
    prefix``rdy = 1; \
    do wait (prefix``stb) @(posedge clk); while (~prefix``stb); \
    d = prefix``dat; \
    #1 prefix``rdy = 0; \
  end \
  endtask : prefix``rcv

`define xmt(prefix=) \
  logic prefix``stb = 0; \
  logic [7:0] prefix``dat; \
  logic prefix``rdy; \
  task prefix``xmt(input [7:0] d); \
  begin \
    prefix``stb = 1; \
    prefix``dat = d; \
    do wait (prefix``rdy) @(posedge clk); while (~prefix``rdy); \
    #1 prefix``stb = 0; \
  end \
  endtask : prefix``xmt

`endif // INTERFACE_INCLUDED
