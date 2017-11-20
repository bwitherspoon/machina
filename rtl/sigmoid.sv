module sigmoid (
  input logic clock,
  input logic reset,
  input logic train,

  input logic argument_valid,
  input logic [15:0] argument_data,
  output logic argument_ready,

  output logic result_valid,
  output logic [7:0] result_data,
  input logic result_ready,

  input logic error_valid,
  input logic [15:0] error_data,
  output logic error_ready,

  output logic propagate_valid,
  output logic [15:0] propagate_data,
  input logic propagate_ready
);
  function real f(int value, real rate = 1.0);
    return 1.0 / (1.0 + $exp(-rate * $itor(value) / 2.0**8));
  endfunction

  logic [7:0] activation [2**12];
  logic [7:0] result;
  logic [7:0] derivative;
  logic signed [15:0] error;

`ifndef NOENUM
  enum logic [1:0] { ARG, RES, ERR, PRP } state = ARG;
`else
  localparam ARG = 2'd0;
  localparam RES = 2'd1;
  localparam ERR = 2'd2;
  localparam PRP = 2'd3;
  logic [1:0] state = ARG;
`endif

  initial begin
    for (int n = -6 <<< 8; n < 6 <<< 8; n++)
      activation[n[11:0]] = 8'($rtoi(2.0**8 * f(n)));
  end

  always @ (posedge clock) begin
    case (state)
      ARG:
        if (argument_valid & argument_ready)
          state <= RES;
      RES:
        if (result_valid & result_ready)
          state <= (train) ? ERR : ARG;
      ERR:
        if (error_valid & error_ready)
          state <= PRP;
      PRP:
        if (propagate_valid & propagate_ready)
          state <= ARG;
      default:
        $error("Invalid state: %h", state);
    endcase
  end

  assign argument_ready = state == ARG;

  always @ (posedge clock) begin
    if (argument_valid & argument_ready) begin
      if ($signed(argument_data) >= 6 <<< 8)
        result <= 8'hff;
      else if ($signed(argument_data) < -6 <<< 8)
        result <= 8'h00;
      else
        result <= activation[argument_data[11:0]];
    end
  end

  always @ (posedge clock) begin
    if (reset) begin
      result_valid <= '0;
    end else if (state == RES) begin
      if (!result_valid) begin
        result_valid <= '1;
        result_data <= result;
      end else if (result_ready) begin
        result_valid <= '0;
      end
    end
  end

  assign error_ready = state == ERR;

  always @ (posedge clock) begin
    if (error_valid & error_ready) begin
      error <= error_data;
      derivative <= result * (2**8 - result) >>> 8;
    end
  end

  always @ (posedge clock) begin
    if (reset) begin
      propagate_valid <= '0;
    end else if (state == PRP) begin
      if (!propagate_valid) begin
        propagate_valid <= '1;
        propagate_data <= error * $signed({1'b0, derivative}) >>> 8;
      end else if (propagate_ready) begin
        propagate_valid <= '1;
      end
    end
  end

endmodule
