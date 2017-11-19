module logistic (
  input logic clock,
  input logic reset,
  input logic train,

  input logic argument_valid,
  input logic [15:0] argument_data,
  output logic argument_ready,

  input logic feedback_valid,
  input logic [15:0] feedback_data,
  output logic feedback_ready,

  output logic activation_valid,
  output logic [7:0] activation_data,
  input logic activation_ready,

  output logic delta_valid,
  output logic [15:0] delta_data,
  input logic delta_ready
);
  function real f(int value, real rate = 1.0);
    return 1.0 / (1.0 + $exp(-rate * $itor(value) / 2.0**8));
  endfunction

  logic [7:0] activation [2**12];
  logic [7:0] result;
  logic [7:0] derivative;
  logic signed [15:0] feedback;
  logic signed [15:0] delta;

`ifndef NOENUM
  enum logic [1:0] { ARG, ACT, FBK, DEL } state = ARG;
`else
  localparam ARG = 2'd0;
  localparam ACT = 2'd1;
  localparam FBK = 2'd2;
  localparam DEL = 2'd3;
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
          state <= ACT;
      ACT:
        if (activation_valid & activation_ready)
          state <= (train) ? FBK : ARG;
      FBK:
        if (feedback_valid & feedback_ready)
          state <= DEL;
      DEL:
        if (delta_valid & delta_ready)
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
      activation_valid <= '0;
    end else if (state == ACT) begin
      if (!activation_valid) begin
        activation_valid <= '1;
        activation_data <= result;
      end else if (activation_ready) begin
        activation_valid <= '0;
      end
    end
  end

  assign feedback_ready = state == FBK;

  always @ (posedge clock) begin
    if (feedback_valid & feedback_ready) begin
      feedback <= feedback_data;
      derivative <= result * (2**8 - result) >>> 8;
    end
  end

  always @ (posedge clock) begin
    if (reset) begin
      delta_valid <= '0;
    end else if (state == DEL) begin
      if (!delta_valid) begin
        delta_valid <= '1;
        delta_data <= feedback * $signed({1'b0, derivative}) >>> 8;
      end else if (delta_ready) begin
        delta_valid <= '1;
      end
    end
  end

endmodule
