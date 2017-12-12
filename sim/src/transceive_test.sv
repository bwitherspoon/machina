`include "clock.svh"
`include "dump.svh"
`include "random.svh"
`include "reset.svh"
`include "serial.svh"
`include "test.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam FREQ = 12e6;
  localparam BAUD = 96e2;

  `clock(FREQ)
  `reset
  `serial(BAUD)

  logic rdy;
  logic stb;
  logic err;
  logic [7:0] dat;

  receive  #(BAUD, FREQ) rx (.*);
  transmit #(BAUD, FREQ) tx (.*);

  task testcase;
    logic [7:0] tx;
    logic [7:0] rx;
    repeat (8) begin
      tx = random(255);
      fork
        stx(tx);
        srx(rx);
      join
      `test_equal(err, 0);
      `test_equal(rx, tx);
    end
  endtask

  task test;
    fork
      begin : timeout
        repeat (1e6) @(posedge clk);
        disable worker;
        $error("testbench timeout");
        $stop;
      end : timeout
      begin : worker
        testcase;
        disable timeout;
      end : worker
    join
  endtask

  initial begin
    dump;
    #PERIOD;
    test;
    reset;
    test;
    $finish;
  end

endmodule
