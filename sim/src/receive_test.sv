`include "clock.svh"
`include "dump.svh"
`include "interface.svh"
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
  `slave()

  wire err;

  receive #(BAUD, FREQ) uut (.*);

  task testcase0;
    logic [7:0] tx;
    logic [7:0] rx;
    repeat (8) begin
      tx = random(255);
      fork
        stx(tx);
        rcv(rx);
      join
      `test_equal(rx, tx);
    end
  endtask

  task testcase1;
    logic [7:0] tx;
    logic [7:0] rx;
    repeat (8) begin
      tx = random(255);
      stx(tx);
      rcv(rx);
      `test_equal(tx, rx);
    end
  endtask

  task testcase2;
    logic [7:0] tx [2];
    logic [7:0] rx;
    repeat (8) begin
      tx[0] = random(255);
      stx(tx[0]);
      `test_equal(err, 0);
      tx[1] = random(255);
      fork
        stx(tx[1]);
        #(9.5e9/BAUD) rcv(rx);
      join
      `test_equal(err, 0);
      `test_equal(rx, tx[0]);
      rcv(rx);
      `test_equal(rx, tx[1]);
    end
  endtask

  task test;
  fork
    begin : timeout
      repeat (1e6) @(posedge clk);
      disable worker;
      `ifdef __ICARUS__
        $error("testbench timeout");
        $stop;
      `else
        $fatal(0, "testbench timeout");
      `endif
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
