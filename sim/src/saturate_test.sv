`include "check.svh"
`include "dump.svh"

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  reg  [16:0] val;
  wire [15:0] out;

  saturate uut (.*);

  task test;
    logic [16:0] arg [4];
    logic [15:0] sat [4];
    begin
      arg[0] = 17'h000ff; arg[1] = 17'h1ff00; arg[2] = 17'h07fff; arg[3] = 17'h10000;
      sat[0] = 16'h00ff;  sat[1] = 16'hff00;  sat[2] = 16'h7fff;  sat[3] = 16'h8000;
      for (int i = 0; i < 4; i++) begin
        val = arg[i];
        #1 `check_equal(out, sat[i]);
      end
    end
  endtask

  initial begin
    dump;
    test;
    $finish;
  end

endmodule
