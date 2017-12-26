`include "check.svh"
`include "dump.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  localparam W = 16;
  localparam L = 8;

  reg  [W-1:0] i;
  wire [W-1:0] o;

  saturate #(W, L) uut (.*);

  task test;
    logic [16:0] dat [4];
    logic [15:0] sat [4];
    begin
      dat[0] = 16'h000f; dat[1] = 16'h00f0; dat[2] = 16'h007f; dat[3] = 16'h0100;
      sat[0] = 16'h000f; sat[1] = 16'h00f0; sat[2] = 16'h007f; sat[3] = 16'h0080;
      for (int n = 0; n < 4; n++) begin
        i = dat[n];
        #1 `check_equal(o, sat[n]);
      end
    end
  endtask

  initial begin
    dump;
    test;
    $finish;
  end

endmodule
