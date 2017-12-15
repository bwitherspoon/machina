`ifndef INTERFACE_INCLUDED
`define INTERFACE_INCLUDED

`define master(prefix=, width=8, depth=1, count=1) \
  logic [(count)-1:0] prefix``stb = 0; \
  logic [(count)-1:0][(depth)-1:0][(width)-1:0] prefix``dat; \
  logic [(count)-1:0] prefix``rdy; \
  task prefix``xmt( \
    input [(depth)-1:0][(width)-1:0] d, \
    input [$clog2(count)-1:0] i = 0 \
  ); \
  begin \
    prefix``stb[i] = 1; \
    prefix``dat[i] = d; \
    do wait (prefix``rdy[i]) @(posedge clk); while (~prefix``rdy[i]); \
    #1 prefix``stb[i] = 0; \
  end \
  endtask : prefix``xmt

`define slave(prefix=, width=8, depth=1, count=1) \
  logic [(count)-1:0] prefix``stb; \
  logic [(count)-1:0][(depth)-1:0][(width)-1:0] prefix``dat; \
  logic [(count)-1:0] prefix``rdy = 0; \
  task prefix``rcv( \
    output [(depth)-1:0][(width)-1:0] d, \
    input [$clog2(count)-1:0] i = 0 \
  ); \
  begin \
    prefix``rdy[i] = 1; \
    do wait (prefix``stb[i]) @(posedge clk); while (~prefix``stb[i]); \
    d = prefix``dat[i]; \
    #1 prefix``rdy[i] = 0; \
  end \
  endtask : prefix``rcv

`endif // INTERFACE_INCLUDED
