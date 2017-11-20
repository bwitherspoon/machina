module heaviside (
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
  logic signed [15:0] argument;
  logic [15:0] delta;

`ifndef NOENUM
  enum logic [1:0] { ARG, RES, ERR, PRP } state = ARG;
`else
  localparam ARG = 2'd0;
  localparam RES = 2'd1;
  localparam ERR = 2'd2;
  localparam PRP = 2'd3;
  logic [1:0] state = ARG;
`endif

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
    endcase
  end

  assign argument_ready = state == ARG;

  always @ (posedge clock) begin
    if (argument_valid & argument_ready)
      argument <= argument_data;
  end

  always @ (posedge clock) begin
    if (reset) begin
      result_valid <= 0;
    end else if (state == RES) begin
      if (!result_valid) begin
        result_valid <= 1;
        result_data <= (argument >= 0) ? 8'hff : 8'h00;
      end else if (result_ready) begin
        result_valid <= 0;
      end
    end
  end

  assign error_ready = state == ERR;

  always @ (posedge clock) begin
    if (error_valid & error_ready)
      delta <= error_data;
  end

  always @ (posedge clock) begin
    if (reset) begin
      propagate_valid <= 0;
    end else if (state == PRP) begin
      if (!propagate_valid) begin
        propagate_valid <= 1;
        propagate_data <= delta;
      end else if (propagate_ready) begin
        propagate_valid <= 0;
      end
    end
  end

endmodule
