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
  logic rdy = 0;
  logic stb;
  logic [7:0] dat;
  logic [7:0] res;

  always #(PERIOD/2) clk = (clk === 0);

  receive #(BAUDRATE, FREQUENCY) uut (.*);

  task xmt;
    input [7:0] data;
    begin
      #1 rxd = 0;
      #(CYCLES*PERIOD);
      for (int i = 0; i < 8; i++) begin
        rxd = data[i];
        #(CYCLES*PERIOD);
      end
      rxd = 1;
      #(CYCLES*PERIOD);
    end
  endtask

  task rcv;
    output [7:0] data;
    begin
      fork
        begin : timeout
          repeat (10000) @(posedge clk);
          disable worker;
          `DEBUG("receiver timeout");
          data = 8'hxx;
        end : timeout
        begin : worker
          wait (stb) rdy = 1;
          @(posedge clk) `ASSERT_EQUAL(stb, 1);
          data = dat;
          #1 rdy = 0;
          disable timeout;
        end : worker
      join
    end
  endtask

  initial begin
    dump;
    #(PERIOD/2) reset;
    xmt(8'h8F);
    rcv(res);
    `ASSERT_EQUAL(res, 8'h8f);
    xmt(8'hf8);
    rcv(res);
    `ASSERT_EQUAL(res, 8'hf8);
    $finish;
  end

endmodule
