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

  logic [1:0][7:0] operand [4];
  logic [15:0] target [4];
  logic [15:0] product;
  logic signed [15:0] delta;
  logic [1:0][15:0] feedback;

  node #(.N(2), .K(2), .SEED(0)) dut (
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
    // Test 1
    reset = 1;
    repeat (2) @ (posedge clock);
    #1 reset = 0;

    @ (negedge clock) operand_valid = 1;
    operand_data[0] = 8'h7f;
    operand_data[1] = 8'h7f;
    wait (operand_ready == 1) @ (posedge clock);
    #1 operand_valid = 0;

    wait (product_valid == 1) #1 product_ready = 1;
    @ (posedge clock) product = product_data;
    if (product != 16'hfff9) begin
      $error("product invalid: %h", product);
      $stop;
    end
    #1 product_ready = 0;

    wait (operand_ready == 1) @ (posedge clock) #1 train = 1;

    operand_valid = 1;
    operand_data[0] = 8'hff;
    operand_data[1] = 8'hff;
    wait (operand_ready == 1) @ (posedge clock);
    #1 operand_valid = 0;

    wait (product_valid == 1) #1 product_ready = 1;
    @ (posedge clock) product = product_data;
    if (product != 16'hfff4) begin
      $error("product invalid: %h", product);
      $stop;
    end
    #1 product_ready = 0;

    @ (negedge clock) delta_valid = 1;
    delta_data = 16'h0000;
    wait (delta_ready == 1) @ (posedge clock);
    #1 delta_valid = 0;

    wait (feedback_valid == 1) #1 feedback_ready = 1;
    @ (posedge clock) feedback = feedback_data;
    if (feedback != 16'h00) begin
      $error("feedback invalid: %h", feedback);
      $stop;
    end
    #1 feedback_ready = 0;

    // Test 2
    operand[0] = 16'h0000;
    operand[1] = 16'h00ff;
    operand[2] = 16'hff00;
    operand[3] = 16'hffff;
    target[0] = 16'hff00;
    target[1] = 16'h007f;
    target[2] = 16'hff00;
    target[3] = 16'h007f;

    repeat (25) begin
      for (int i = 0; i < 4; i++) begin
        operand_valid = 1;
        operand_data = operand[i];
        wait (operand_ready == 1) @ (posedge clock);
        #1 operand_valid = 0;

        wait (product_valid == 1) #1 product_ready = 1;
        @ (posedge clock) product = product_data;
        #1 product_ready = 0;

        @ (negedge clock) delta_valid = 1;
        delta_data = $unsigned($signed(target[i]) - $signed(product));
        wait (delta_ready == 1) @ (posedge clock);
        #1 delta_valid = 0;

        wait (feedback_valid == 1) #1 feedback_ready = 1;
        @ (posedge clock) feedback = feedback_data;
        #1 feedback_ready = 0;
      end
    end

    for (int i = 0; i < 4; i++) begin
      operand_valid = 1;
      operand_data = operand[i];
      wait (operand_ready == 1) @ (posedge clock);
      #1 operand_valid = 0;

      wait (product_valid == 1) #1 product_ready = 1;
      @ (posedge clock) product = product_data;
      #1 product_ready = 0;

      @ (negedge clock) delta_valid = 1;
      delta = $signed(target[i]) - $signed(product);
      delta_data = $unsigned(delta);
`ifdef DEBUG
      $write("%6.3f * %6.3f + ", dut.weight[1] / 256.0, operand[i][1] / 256.0);
      $write("%6.3f * %6.3f + ", dut.weight[0] / 256.0, operand[i][0] / 256.0);
      $write("%6.3f = %6.3f ? ", dut.bias / 256.0, $signed(product) / 256.0);
      $write("%6.3f ! %6.3f\n", $signed(target[i]) / 256.0, $signed(delta_data) / 256.0);
`endif
      wait (delta_ready == 1) @ (posedge clock);
      #1 delta_valid = 0;
      if (((delta[15]) ? -delta : delta) > 4) begin
        $error("error out of range: %6.3f", delta / 256.0);
        $stop;
      end

      wait (feedback_valid == 1) #1 feedback_ready = 1;
      @ (posedge clock) feedback = feedback_data;
      #1 feedback_ready = 0;
    end

    $finish(0);
  end

endmodule
