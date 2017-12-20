`include "clock.svh"
`include "dump.svh"
`include "reset.svh"
`include "serial.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam FREQ = 12000000;
  localparam BAUD = 9600;

  `clock(FREQ)
  `serial(BAUD,, rs232_)

  wire rs232_rts = 0;
  wire rs232_dtr = 0;
  wire rs232_cts;
  wire rs232_dcd;
  wire rs232_dsr;
  wire irda_rxd = 0;
  wire irda_txd;
  wire irda_sd;
  wire [4:0] led;
  wire [7:0] pmod;
  wire [15:0] gpio;

  icestick ice (.*);

  wire nc = &{1'b0,
              rs232_cts,
              rs232_dcd,
              rs232_dsr,
              irda_txd,
              irda_sd,
              led,
              pmod,
              gpio,
              1'b0};

  task testcase;
    @(posedge clk);
  endtask : testcase

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
      testcase;
      disable timeout;
    end : worker
  join
  endtask : test

  initial begin
    dump;
    #PERIOD;
    test;
    $finish;
  end

endmodule
