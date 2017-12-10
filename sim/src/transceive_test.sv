module top;
  timeunit 1ns;
  timeprecision 1ps;

  `include "debug.vh"
  `include "util.svh"
  `include "clock.svh"

  parameter BAUDRATE = 96e2;

  localparam CYCLES = $rtoi(FREQUENCY / BAUDRATE);

  logic rst;

  logic rxd = 1;
  logic txd;
  logic rdy;
  logic stb;
  logic [7:0] dat;
  logic err;

  logic [7:0] res;

  receive #(BAUDRATE, FREQUENCY) rx (.*);

  transmit #(BAUDRATE, FREQUENCY) tx (.*);

  task xmt;
    input [7:0] d;
    begin
      #1 rxd = 0;
      #(CYCLES*PERIOD);
      for (int i = 0; i < 8; i++) begin
        rxd = d[i];
        #(CYCLES*PERIOD);
      end
      rxd = 1;
      #(CYCLES*PERIOD);
    end
  endtask

  task rcv;
    output [7:0] d;
    begin
      wait (txd == 0);
      #(CYCLES*PERIOD/2);
      `ASSERT_EQUAL(txd, 0);
      #(CYCLES*PERIOD);
      for (int i = 0; i < 8; i++) begin
        d[i] = txd;
        #(CYCLES*PERIOD);
      end
      `ASSERT_EQUAL(txd, 1);
      #(CYCLES*PERIOD);
    end
  endtask

  task test0;
    begin
      fork
        xmt(8'h8f);
        rcv(res);
      join
      `ASSERT_EQUAL(res, 8'h8f);
      fork
        xmt(8'hf8);
        rcv(res);
      join
      `ASSERT_EQUAL(res, 8'hf8);
      fork
        xmt(8'h77);
        rcv(res);
      join
      `ASSERT_EQUAL(res, 8'h77);
    end
  endtask

  task test1;
    begin
      xmt(8'h55);
      xmt(8'haa);
      rcv(res);
      `ASSERT_EQUAL(res, 8'h55);
      rcv(res);
      `ASSERT_EQUAL(res, 8'haa);
    end
  endtask

  initial begin
    dump;
    #(PERIOD/2) reset;
    test0;
    test1;
    $finish;
  end

endmodule
