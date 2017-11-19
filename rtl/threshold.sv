module threshold (
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
  logic signed [15:0] argument;
  logic [15:0] feedback;

  enum logic [1:0] { ARG, ACT, FBK, DEL } state = ARG;

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
        $error("invalid state: %h", state);
    endcase
  end

  assign argument_ready = state == ARG;

  always @ (posedge clock) begin
    if (argument_valid & argument_ready)
      argument <= argument_data;
  end

  always @ (posedge clock) begin
    if (reset) begin
      activation_valid <= '0;
    end else if (state == ACT) begin
      if (!activation_valid) begin
        activation_valid <= '1;
        activation_data <= (argument >= 0) ? 8'hff : 8'h00;
      end else if (activation_ready) begin
        activation_valid <= '0;
      end
    end
  end

  assign feedback_ready = state == FBK;

  always @ (posedge clock) begin
    if (feedback_valid & feedback_ready)
      feedback <= feedback_data;
  end

  always @ (posedge clock) begin
    if (reset) begin
      delta_valid <= '0;
    end else if (state == DEL) begin
      if (!delta_valid) begin
        delta_valid <= '1;
        delta_data <= feedback;
      end else if (delta_ready) begin
        delta_valid <= '1;
      end
    end
  end

endmodule
