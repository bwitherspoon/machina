`ifndef INTERFACE_INCLUDED
`define INTERFACE_INCLUDED

`include "clock.svh"

parameter TIMEOUT = 100000;

logic inf_xmt_stb = 0;
logic [7:0] inf_xmt_dat;
logic inf_xmt_rdy;

task inf_xmt;
  input [7:0] dat;
  fork
    begin : timeout
      repeat (TIMEOUT) @(posedge clk);
      disable worker;
      $warning("transmit timeout after %0d clock cycles", TIMEOUT);
    end : timeout
    begin : worker
      inf_xmt_stb = 1;
      inf_xmt_dat = dat;
      do wait (inf_xmt_rdy) @(posedge clk); while (~inf_xmt_rdy);
      #1 inf_xmt_stb = 0;
      disable timeout;
    end : worker
  join
endtask : inf_xmt

logic inf_rcv_stb;
logic [7:0] inf_rcv_dat;
logic inf_rcv_rdy = 0;

task inf_rcv;
  output [7:0] dat;
  fork
    begin : timeout
      repeat (TIMEOUT) @(posedge clk);
      disable worker;
      $warning("receive timeout after %0d clock cycles", TIMEOUT);
    end : timeout
    begin : worker
      inf_rcv_rdy = 1;
      do wait (inf_rcv_stb) @(posedge clk); while (~inf_rcv_stb);
      dat = inf_rcv_dat;
      #1 inf_rcv_rdy = 0;
      disable timeout;
    end : worker
  join
endtask : inf_rcv

`endif // INTERFACE_INCLUDED
