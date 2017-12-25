`ifndef CONNECT_INCLUDED
`define CONNECT_INCLUDED

`define connect(master=m, slave=s, width=8, depth=1, count=1) \
  logic [(count)-1:0] master``_stb; \
  logic [(count)-1:0][(depth)-1:0][(width)-1:0] master``_dat; \
  logic [(count)-1:0] master``_rdy; \
  logic [(count)-1:0] slave``_stb; \
  logic [(count)-1:0][(depth)-1:0][(width)-1:0] slave``_dat; \
  logic [(count)-1:0] slave``_rdy; \
  assign master``_rdy = slave``_rdy; \
  assign slave``_stb = master``_stb; \
  assign slave``_dat = master``_dat;

`define master(width=8, depth=1, count=1, prefix=m) \
  logic [(count)-1:0] prefix``_stb; \
  logic [(count)-1:0][(depth)-1:0][(width)-1:0] prefix``_dat; \
  logic [(count)-1:0] prefix``_rdy = 0; \
  task prefix``_get( \
    output [(depth)-1:0][(width)-1:0] dat, \
    input [$clog2(count)-1:0] idx = 0 \
  ); \
  begin \
    prefix``_rdy[idx] = 1; \
    do wait (prefix``_stb[idx]) @(posedge clk); while (~prefix``_stb[idx]); \
    dat = prefix``_dat[idx]; \
    #1 prefix``_rdy[idx] = 0; \
  end \
  endtask : prefix``_get

`define slave(width=8, depth=1, count=1, prefix=s) \
  logic [(count)-1:0] prefix``_stb = 0; \
  logic [(count)-1:0][(depth)-1:0][(width)-1:0] prefix``_dat; \
  logic [(count)-1:0] prefix``_rdy; \
  task prefix``_put( \
    input [(depth)-1:0][(width)-1:0] dat, \
    input [$clog2(count)-1:0] idx = 0 \
  ); \
  begin \
    prefix``_stb[idx] = 1; \
    prefix``_dat[idx] = dat; \
    do wait (prefix``_rdy[idx]) @(posedge clk); while (~prefix``_rdy[idx]); \
    #1 prefix``_stb[idx] = 0; \
  end \
  endtask : prefix``_put

`endif // CONNECT_INCLUDED
