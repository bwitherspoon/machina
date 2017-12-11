`ifndef SERIAL_INCLUDED
`define SERIAL_INCLUDED

`include "debug.vh"
`include "clock.svh"

parameter BAUDRATE = 96e2;

localparam CYCLES = $rtoi(FREQUENCY / BAUDRATE);

logic ser_txd;
logic ser_rxd = 1;

task ser_xmt;
  input [7:0] dat;
  begin
    ser_rxd = 0;
    #(CYCLES*PERIOD);
    for (int i = 0; i < 8; i++) begin
      ser_rxd = dat[i];
      #(CYCLES*PERIOD);
    end
    ser_rxd = 1;
    #(CYCLES*PERIOD);
  end
endtask : ser_xmt

task ser_rcv;
  output [7:0] dat;
  begin
    wait (ser_txd == 0);
    #(CYCLES*PERIOD/2);
    `ASSERT_EQUAL(ser_txd, 0);
    #(CYCLES*PERIOD);
    for (int i = 0; i < 8; i++) begin
      dat[i] = ser_txd;
      #(CYCLES*PERIOD);
    end
    `ASSERT_EQUAL(ser_txd, 1);
    #(CYCLES*PERIOD);
  end
endtask : ser_rcv

`endif // SERIAL_INCLUDED
