module node_test;
  bit clock = 0;
  always #5 clock = ~clock;

  bit reset = 0;
  bit train = 0;

  logic argument_valid = 0;
  logic argument_ready;
  logic [1:0][7:0] argument_data;

  logic result_valid;
  logic result_ready = 0;
  logic [15:0] result_data;

  logic error_valid = 0;
  logic error_ready;
  logic [15:0] error_data;

  logic propagate_valid;
  logic propagate_ready = 0;
  logic [1:0][15:0] propagate_data;

  logic [1:0][7:0] argument [4];
  logic [15:0] target [4];
  logic [15:0] result;
  logic signed [15:0] delta;
  logic [1:0][15:0] propagate;

  node #(.N(2), .S(2), .SEED(0)) dut (
    .clock(clock),
    .reset(reset),
    .train(train),
    .argument_valid(argument_valid),
    .argument_data(argument_data),
    .argument_ready(argument_ready),
    .result_valid(result_valid),
    .result_data(result_data),
    .result_ready(result_ready),
    .error_valid(error_valid),
    .error_data(error_data),
    .error_ready(error_ready),
    .propagate_valid(propagate_valid),
    .propagate_data(propagate_data),
    .propagate_ready(propagate_ready)
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

    @ (negedge clock) argument_valid = 1;
    argument_data[0] = 8'h7f;
    argument_data[1] = 8'h7f;
    wait (argument_ready == 1) @ (posedge clock);
    #1 argument_valid = 0;

    wait (result_valid == 1) #1 result_ready = 1;
    @ (posedge clock) result = result_data;
    if (result != 16'hfff9) begin
      $error("result invalid: %h", result);
      $stop;
    end
    #1 result_ready = 0;

    wait (argument_ready == 1) @ (posedge clock) #1 train = 1;

    argument_valid = 1;
    argument_data[0] = 8'hff;
    argument_data[1] = 8'hff;
    wait (argument_ready == 1) @ (posedge clock);
    #1 argument_valid = 0;

    wait (result_valid == 1) #1 result_ready = 1;
    @ (posedge clock) result = result_data;
    if (result != 16'hfff4) begin
      $error("result invalid: %h", result);
      $stop;
    end
    #1 result_ready = 0;

    @ (negedge clock) error_valid = 1;
    error_data = 16'h0000;
    wait (error_ready == 1) @ (posedge clock);
    #1 error_valid = 0;

    wait (propagate_valid == 1) #1 propagate_ready = 1;
    @ (posedge clock) propagate = propagate_data;
    if (propagate != 16'h00) begin
      $error("propagate invalid: %h", propagate);
      $stop;
    end
    #1 propagate_ready = 0;

    // Test 2
    argument[0] = 16'h0000;
    argument[1] = 16'h00ff;
    argument[2] = 16'hff00;
    argument[3] = 16'hffff;
    target[0] = 16'hff00;
    target[1] = 16'h007f;
    target[2] = 16'hff00;
    target[3] = 16'h007f;

    repeat (25) begin
      for (int i = 0; i < 4; i++) begin
        argument_valid = 1;
        argument_data = argument[i];
        wait (argument_ready == 1) @ (posedge clock);
        #1 argument_valid = 0;

        wait (result_valid == 1) #1 result_ready = 1;
        @ (posedge clock) result = result_data;
        #1 result_ready = 0;

        @ (negedge clock) error_valid = 1;
        error_data = $unsigned($signed(target[i]) - $signed(result));
        wait (error_ready == 1) @ (posedge clock);
        #1 error_valid = 0;

        wait (propagate_valid == 1) #1 propagate_ready = 1;
        @ (posedge clock) propagate = propagate_data;
        #1 propagate_ready = 0;
      end
    end

    for (int i = 0; i < 4; i++) begin
      argument_valid = 1;
      argument_data = argument[i];
      wait (argument_ready == 1) @ (posedge clock);
      #1 argument_valid = 0;

      wait (result_valid == 1) #1 result_ready = 1;
      @ (posedge clock) result = result_data;
      #1 result_ready = 0;

      @ (negedge clock) error_valid = 1;
      delta = $signed(target[i]) - $signed(result);
      error_data = $unsigned(delta);
`ifdef DEBUG
      $write("DEBUG: ");
      $write("%6.3f * %6.3f + ", dut.weight[1] / 256.0, argument[i][1] / 256.0);
      $write("%6.3f * %6.3f + ", dut.weight[0] / 256.0, argument[i][0] / 256.0);
      $write("%6.3f = %6.3f ? ", dut.bias / 256.0, $signed(result) / 256.0);
      $write("%6.3f ! %6.3f\n", $signed(target[i]) / 256.0, $signed(delta) / 256.0);
`endif
      wait (error_ready == 1) @ (posedge clock);
      #1 error_valid = 0;
      if (((delta[15]) ? -delta : delta) > 4) begin
        $display("ERROR: error out of range: %6.3f", delta / 256.0);
        $stop;
      end

      wait (propagate_valid == 1) #1 propagate_ready = 1;
      @ (posedge clock) propagate = propagate_data;
      #1 propagate_ready = 0;
    end
    // Success
    $finish;
  end

endmodule
