module node_test;
`include "test.svh"

  function logic [15:0] abs(logic [15:0] val);
    return (val[15]) ? -val : val;
  endfunction

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

  logic [1:0][7:0] arg [4];
  logic [15:0] tgt [4];
  logic [15:0] res;
  logic signed [15:0] err;
  logic [1:0][15:0] prp;

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
    @ (posedge clock) res = result_data;
    if (res != 16'hfff9) begin
      $display("ERROR: result invalid: %h", res);
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
    @ (posedge clock) res = result_data;
    if (res != 16'hfff4) begin
      $display("ERROR: result invalid: %h", res);
      $stop;
    end
    #1 result_ready = 0;

    @ (negedge clock) error_valid = 1;
    error_data = 16'h0000;
    wait (error_ready == 1) @ (posedge clock);
    #1 error_valid = 0;

    wait (propagate_valid == 1) #1 propagate_ready = 1;
    @ (posedge clock) prp = propagate_data;
    if (prp != 16'h00) begin
      $display("ERROR: propagation invalid: %h", prp);
      $stop;
    end
    #1 propagate_ready = 0;

    // Test 2
    arg[0] = 16'h0000;
    arg[1] = 16'h00ff;
    arg[2] = 16'hff00;
    arg[3] = 16'hffff;
    tgt[0] = 16'hff00;
    tgt[1] = 16'h007f;
    tgt[2] = 16'hff00;
    tgt[3] = 16'h007f;
    // Train
    repeat (25) begin
      for (int i = 0; i < 4; i++) begin
        argument_valid = 1;
        argument_data = arg[i];
        wait (argument_ready == 1) @ (posedge clock);
        #1 argument_valid = 0;

        wait (result_valid == 1) #1 result_ready = 1;
        @ (posedge clock) res = result_data;
        #1 result_ready = 0;

        @ (negedge clock) error_valid = 1;
        error_data = $unsigned($signed(tgt[i]) - $signed(res));
        wait (error_ready == 1) @ (posedge clock);
        #1 error_valid = 0;

        wait (propagate_valid == 1) #1 propagate_ready = 1;
        @ (posedge clock) prp = propagate_data;
        #1 propagate_ready = 0;
      end
    end
    // Validate
    for (int i = 0; i < 4; i++) begin
      argument_valid = 1;
      argument_data = arg[i];
      wait (argument_ready == 1) @ (posedge clock);
      #1 argument_valid = 0;

      wait (result_valid == 1) #1 result_ready = 1;
      @ (posedge clock) res = result_data;
      #1 result_ready = 0;

      @ (negedge clock) error_valid = 1;
      err = $signed(tgt[i]) - $signed(res);
      error_data = $unsigned(err);
`ifdef DEBUG
      $write("DEBUG: ");
      $write("%6.3f * %6.3f + ", dut.weight[1] / 256.0, arg[i][1] / 256.0);
      $write("%6.3f * %6.3f + ", dut.weight[0] / 256.0, arg[i][0] / 256.0);
      $write("%6.3f = %6.3f ? ", dut.bias / 256.0, $signed(res) / 256.0);
      $write("%6.3f ! %6.3f\n", $signed(tgt[i]) / 256.0, $signed(err) / 256.0);
`endif
      wait (error_ready == 1) @ (posedge clock);
      #1 error_valid = 0;
      if (abs(err) > 4) begin
        $display("ERROR: error out of range: %6.3f", err / 256.0);
        $stop;
      end

      // TODO verify propagation
      wait (propagate_valid == 1) #1 propagate_ready = 1;
      @ (posedge clock) prp = propagate_data;
      #1 propagate_ready = 0;
    end
    // Success
    $finish;
  end

endmodule
