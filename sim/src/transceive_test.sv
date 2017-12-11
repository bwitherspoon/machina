module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  `include "clock.svh"
  `include "debug.vh"
  `include "dump.svh"
  `include "random.svh"
  `include "reset.svh"
  `include "serial.svh"

  `stx()
  `srx()

  logic rdy;
  logic stb;
  logic err;
  logic [7:0] dat;

  receive  #(BAUDRATE, FREQUENCY) rx (.*);
  transmit #(BAUDRATE, FREQUENCY) tx (.*);

  task testcase;
    logic [7:0] tx;
    logic [7:0] rx;
    repeat (8) begin
      tx = random(255);
      fork
        stx(tx);
        srx(rx);
      join
      `ASSERT_EQUAL(err, 0);
      `ASSERT_EQUAL(rx, tx);
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
