`ifndef INTERFACE_INCLUDED
`define INTERFACE_INCLUDED

`define master(prefix=, width=8, depth=1) \
  logic prefix``stb = 0; \
  logic [(depth)-1:0][(width)-1:0] prefix``dat; \
  logic prefix``rdy; \
  task prefix``xmt(input [(depth)-1:0][(width)-1:0] d); \
  begin \
    prefix``stb = 1; \
    prefix``dat = d; \
    do wait (prefix``rdy) @(posedge clk); while (~prefix``rdy); \
    #1 prefix``stb = 0; \
  end \
  endtask : prefix``xmt

`define slave(prefix=, width=8, depth=1) \
  logic prefix``stb; \
  logic [(depth)-1:0][(width)-1:0] prefix``dat; \
  logic prefix``rdy = 0; \
  task prefix``rcv(output [(depth)-1:0][(width)-1:0] d); \
  begin \
    prefix``rdy = 1; \
    do wait (prefix``stb) @(posedge clk); while (~prefix``stb); \
    d = prefix``dat; \
    #1 prefix``rdy = 0; \
  end \
  endtask : prefix``rcv

`endif // INTERFACE_INCLUDED
