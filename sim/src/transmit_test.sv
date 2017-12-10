module top;
  timeunit 1ns;
  timeprecision 1ps;

  `include "debug.vh"
  `include "util.svh"

  parameter BAUDRATE = 96e2;
  parameter FREQUENCY = 12e6;

  localparam CYCLES = $rtoi(FREQUENCY / BAUDRATE);
  localparam PERIOD = 1.0 / FREQUENCY / 1e-9;

  logic clk;
  logic rst;
  logic stb = 0;
  logic [7:0] dat;
  logic rdy;
  logic txd;

  logic [7:0] res;

  always #(PERIOD/2) clk = (clk === 0);

  transmit #(BAUDRATE, FREQUENCY) uut (.*);

  task xmt;
    input [7:0] data;
    begin
      fork
        begin : timeout
          repeat (10000) @(posedge clk);
          disable worker;
          `DEBUG("transmitter timeout");
          data = 8'hxx;
        end : timeout
        begin : worker
          stb = 1;
          dat = data;
          wait (rdy);
          @(posedge clk) `ASSERT_EQUAL(rdy, 1);
          #1 stb = 0;
          disable timeout;
        end : worker
      join
    end
  endtask

  task rcv;
    output [7:0] data;
    begin
      wait (txd == 0);
      #(CYCLES*PERIOD/2);
      `ASSERT_EQUAL(txd, 0);
      #(CYCLES*PERIOD);
      for (int i = 0; i < 8; i++) begin
        data[i] = txd;
        #(CYCLES*PERIOD);
      end
      `ASSERT_EQUAL(txd, 1);
      #(CYCLES*PERIOD);
    end
  endtask

  initial begin
    dump;
    #(PERIOD/2) reset;
    xmt(8'h55);
    rcv(res);
    `ASSERT_EQUAL(res, 8'h55);
    xmt(8'haa);
    rcv(res);
    `ASSERT_EQUAL(res, 8'haa);
    $finish;
  end

endmodule
