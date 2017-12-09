module top;
  timeunit 1ns;
  timeprecision 1ps;

  `include "debug.vh"
  `include "util.vh"

  parameter BAUDRATE = 96e2;
  parameter FREQUENCY = 12e6;

  localparam CYCLES = $rtoi(FREQUENCY / BAUDRATE);
  localparam PERIOD = 1.0 / FREQUENCY / 1e-9;

  logic clk;
  logic rst;

  logic rxd = 1;
  logic txd;
  logic rdy;
  logic stb;
  logic [7:0] dat;

  logic [7:0] res;

  always #(PERIOD/2) clk = (clk === 0);

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

  initial begin
    dump;
    #(PERIOD/2) reset;
    fork
      xmt(8'h8f);
      rcv(res);
    join
    //`ASSERT_EQUAL(res, 8'h8f);
    repeat(100000) @(posedge clk);
    $finish;
  end

endmodule
