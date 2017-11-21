module perceptron #(
  parameter N = 2
)(
  input logic clock,
  input logic reset,
  input logic train,

  input logic argument_valid,
  input logic [N-1:0][7:0] argument_data,
  output logic argument_ready,

  output logic result_valid,
  output logic [7:0] result_data,
  input logic result_ready,

  input logic error_valid,
  input logic [15:0] error_data,
  output logic error_ready,

  output logic propagate_valid,
  output logic [N-1:0][15:0] propagate_data,
  input logic propagate_ready
);

  wire result_argument_valid;
  wire [15:0] result_argument_data;
  wire result_argument_ready;

  wire error_propagate_valid;
  wire [15:0] error_propagate_data;
  wire error_propagate_ready;

  associate #(.N(N), .S(0)) associator (
    .clock,
    .reset,
    .train,
    .argument_valid,
    .argument_data,
    .argument_ready,
    .result_valid(result_argument_valid),
    .result_data(result_argument_data),
    .result_ready(result_argument_ready),
    .error_valid(error_propagate_valid),
    .error_data(error_propagate_data),
    .error_ready(error_propagate_ready),
    .propagate_valid,
    .propagate_data,
    .propagate_ready
  );

  heaviside activator (
    .clock,
    .reset,
    .train,
    .argument_valid(result_argument_valid),
    .argument_data(result_argument_data),
    .argument_ready(result_argument_ready),
    .result_valid,
    .result_data,
    .result_ready,
    .error_valid,
    .error_data,
    .error_ready,
    .propagate_valid(error_propagate_valid),
    .propagate_data(error_propagate_data),
    .propagate_ready(error_propagate_ready)
  );

endmodule
