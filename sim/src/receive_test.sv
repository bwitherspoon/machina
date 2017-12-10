module top;
  timeunit 1ns;
  timeprecision 1ps;

  `include "debug.vh"
  `include "util.svh"
  `include "reset.svh"
  `include "clock.svh"

  parameter BAUDRATE = 96e2;

  localparam CYCLES = $rtoi(FREQUENCY / BAUDRATE);
  localparam TIMEOUT = 10 * CYCLES * PERIOD;

  logic rxd = 1;
  logic rdy = 0;
  logic stb;
  logic [7:0] dat;
  logic err;

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
          $warning("receive timeout after %0d clock cycles", TIMEOUT);
          data = 8'hxx;
        end : timeout
        begin : worker
          do begin
            wait (stb) #1 rdy = 1;
            @(posedge clk);
          end while (~stb);
          data = dat;
          #1 rdy = 0;
          disable timeout;
        end : worker
      join
    end
  endtask

  task test0;
    logic [7:0] xmtd;
    logic [7:0] rcvd;
    repeat (8) begin
      xmtd = random(255);
      fork
        xmt(xmtd);
        rcv(rcvd);
      join
      `ASSERT_EQUAL(xmtd, rcvd);
    end
  endtask

  task test1;
    logic [7:0] xmtd;
    logic [7:0] rcvd;
    repeat (8) begin
      xmtd = random(255);
      xmt(xmtd);
      rcv(rcvd);
      `ASSERT_EQUAL(xmtd, rcvd);
    end
  endtask

  task test2;
    logic [7:0] xmtd [2];
    logic [7:0] rcvd;
    repeat (8) begin
      xmtd[0] = random(255);
      xmt(xmtd[0]);
      `ASSERT_EQUAL(err, 0);
      xmtd[1] = random(255);
      fork
        xmt(xmtd[1]);
        #(9.5*CYCLES*PERIOD) rcv(rcvd);
      join
      `ASSERT_EQUAL(err, 0);
      `ASSERT_EQUAL(rcvd, xmtd[0]);
      rcv(rcvd);
      `ASSERT_EQUAL(rcvd, xmtd[1]);
    end
  endtask

  function int unsigned random(int unsigned max = 2**32);
    int seed = 0;
    return {$random(seed)} % max;
  endfunction : random

  task seed;
    if ($test$plusargs("seed") && !$value$plusargs("seed=%d", random.seed))
      $error("invalid seed");
    else
      $info("using seed %0d", random.seed);
  endtask : seed

  task test;
    test0;
    test1;
    test2;
  endtask

  initial begin
    dump;
    seed;
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
