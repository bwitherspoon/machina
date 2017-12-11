module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  `include "clock.svh"
  `include "debug.vh"
  `include "dump.svh"
  `include "interface.svh"
  `include "random.svh"
  `include "reset.svh"
  `include "serial.svh"

  `rcv()
  `stx()
  wire err;
  receive #(BAUDRATE, FREQUENCY) uut (.*);

  task testcase0;
    logic [7:0] tx;
    logic [7:0] rx;
    repeat (8) begin
      tx = random(255);
      fork
        stx(tx);
        rcv(rx);
      join
      `ASSERT_EQUAL(rx, tx);
    end
  endtask

  task testcase1;
    logic [7:0] tx;
    logic [7:0] rx;
    repeat (8) begin
      tx = random(255);
      stx(tx);
      rcv(rx);
      `ASSERT_EQUAL(tx, rx);
    end
  endtask

  task testcase2;
    logic [7:0] tx [2];
    logic [7:0] rx;
    repeat (8) begin
      tx[0] = random(255);
      stx(tx[0]);
      `ASSERT_EQUAL(err, 0);
      tx[1] = random(255);
      fork
        stx(tx[1]);
        #(9.5*CYCLES_PER_SYMBOL*PERIOD) rcv(rx);
      join
      `ASSERT_EQUAL(err, 0);
      `ASSERT_EQUAL(rx, tx[0]);
      rcv(rx);
      `ASSERT_EQUAL(rx, tx[1]);
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
        testcase0;
        testcase1;
        testcase2;
        disable timeout;
      end : worker
    join
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
