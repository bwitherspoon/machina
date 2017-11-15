module test;
  timeunit 1ns;
  timeprecision 1ps;

  localparam WIDTH = 8;
  localparam DEPTH = 3;

  // Clock (100 MHz)
  bit clock;
  always #5 clock <= ~clock;

  // Reset
  bit reset;

  // Signals
  logic input_valid;
  logic input_ready;
  logic [DEPTH-1:0][WIDTH-1:0] input_data;
  logic output_valid;
  logic output_ready;
  logic [WIDTH-1:0] output_data;

  node #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
    .clock(clock),
    .reset(reset),
    .input_valid(input_valid),
    .input_data(input_data),
    .input_ready(input_ready),
    .output_valid(output_valid),
    .output_data(output_data),
    .output_ready(output_ready)
  );

  initial begin
    $dumpfile("test.vcd");
    $dumpvars;
    reset = 1;
    #20 reset = 0;
    for (int i = 0; i < DEPTH; i = i + 1) begin
      input_data[i] = $random % 2**($bits(input_data[i])-1);;
    end
    input_valid = 1;
    output_ready = 1;
    $info("Running...");
    #200 $info("Finished");
    $finish(0);
  end

endmodule
