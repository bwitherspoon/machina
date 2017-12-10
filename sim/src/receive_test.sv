module top;
  timeunit 1ns;
  timeprecision 1ps;

  `include "debug.vh"
  `include "util.vh"

  parameter BAUDRATE = 96e2;
  parameter FREQUENCY = 12e6;

  localparam CYCLES = $rtoi(FREQUENCY / BAUDRATE);
  localparam PERIOD = 1 / FREQUENCY / 1e-9;
  localparam TIMEOUT = 25 * CYCLES * PERIOD;

  logic clk;
  logic rst;
  logic rxd = 1;
  logic rdy = 0;
  logic stb;
  logic [7:0] dat;

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
          repeat (TIMEOUT) @(posedge clk);
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

  task test0;
    logic [7:0] tx;
    logic [7:0] rx;
    begin
      repeat (4) begin
        tx = {$random(seed)} % 255;
        fork
          xmt(tx);
          rcv(rx);
        join
        `ASSERT_EQUAL(tx, rx);
      end
    end
  endtask

  task test1;
    logic [7:0] tx [2];
    logic [7:0] rx;
    begin
      for (int i = 0; i < 2; i++) begin
        tx[i] = {$random(seed)} % 255;
        xmt(tx[i]);
      end
      for (int i = 0; i < 2; i++) begin
        rcv(rx);
        `ASSERT_EQUAL(rx, tx[i]);
      end
    end
  endtask

  int seed = 0;

  initial begin
    dump;
    if ($value$plusargs("seed=%d", seed)) $info("using seed %0d", seed);
    #(PERIOD/2) reset;
    test0;
    test1;
    $finish;
  end

endmodule
