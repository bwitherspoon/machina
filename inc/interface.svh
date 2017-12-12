`ifndef INTERFACE_INCLUDED
`define INTERFACE_INCLUDED

`define rcv(prefix=, width=8) \
  logic prefix``stb; \
  logic [(width)-1:0] prefix``dat; \
  logic prefix``rdy = 0; \
  task prefix``rcv(output [(width)-1:0] d); \
  begin \
    prefix``rdy = 1; \
    do wait (prefix``stb) @(posedge clk); while (~prefix``stb); \
    d = prefix``dat; \
    #1 prefix``rdy = 0; \
  end \
  endtask : prefix``rcv

`define xmt(prefix=, width=8) \
  logic prefix``stb = 0; \
  logic [(width)-1:0] prefix``dat; \
  logic prefix``rdy; \
  task prefix``xmt(input [(width)-1:0] d); \
  begin \
    prefix``stb = 1; \
    prefix``dat = d; \
    do wait (prefix``rdy) @(posedge clk); while (~prefix``rdy); \
    #1 prefix``stb = 0; \
  end \
  endtask : prefix``xmt

`endif // INTERFACE_INCLUDED
