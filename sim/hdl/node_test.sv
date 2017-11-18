module node_test;
  timeunit 1ns;
  timeprecision 1ps;

  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic operand_valid = 0;
  logic operand_ready;
  logic [1:0][7:0] operand_data;

  logic product_valid;
  logic product_ready = 0;
  logic [15:0] product_data;

  logic delta_valid = 0;
  logic delta_ready;
  logic [15:0] delta_data;

  logic feedback_valid;
  logic feedback_ready = 0;
  logic [1:0][15:0] feedback_data;

  logic [15:0] product;
  logic [1:0][15:0] feedback;

  node #(.N(2), .K(2), .SEED(255)) dut (
    .clock(clock),
    .reset(reset),
    .train(train),
    .operand_valid(operand_valid),
    .operand_data(operand_data),
    .operand_ready(operand_ready),
    .product_valid(product_valid),
    .product_data(product_data),
    .product_ready(product_ready),
    .delta_valid(delta_valid),
    .delta_data(delta_data),
    .delta_ready(delta_ready),
    .feedback_valid(feedback_valid),
    .feedback_data(feedback_data),
    .feedback_ready(feedback_ready)
  );

  initial begin
`ifdef DUMPFILE
    $dumpfile(`"`DUMPFILE`");
    $dumpvars;
`endif

    reset = 1;
    #20 reset = 0;

    @ (negedge clock) operand_valid = 1;
    operand_data[0] = 8'h00;
    operand_data[1] = 8'h00;
    wait (operand_ready == 1) @ (posedge clock);
    #1 operand_valid = 0;

    wait (product_valid == 1) #1 product_ready = 1;
    @ (posedge clock) product = product_data;
    if (product != 8'h00)
      $fatal(0, "product invalid: %h", product);
    #1 product_ready = 0;

    wait (operand_ready == 1) @ (posedge clock) #1 train = 1;

    operand_valid = 1;
    operand_data[0] = 8'h00;
    operand_data[1] = 8'h00;
    wait (operand_ready == 1) @ (posedge clock);
    #1 operand_valid = 0;

    wait (product_valid == 1) #1 product_ready = 1;
    @ (posedge clock) product = product_data;
    if (product != 8'h00)
      $fatal(0, "product invalid: %h", product);
    #1 product_ready = 0;

    @ (negedge clock) delta_valid = 1;
    delta_data = 16'h0000;
    wait (delta_ready == 1) @ (posedge clock);
    #1 delta_valid = 0;

    wait (feedback_valid == 1) #1 feedback_ready = 1;
    @ (posedge clock) feedback = feedback_data;
    if (feedback != 16'h00)
      $fatal(0, "feedback invalid: %h", feedback);
    #1 feedback_ready = 0;

    $finish(0);
  end

endmodule
