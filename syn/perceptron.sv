module perceptron #(
  parameter N = 2
)(
  input logic clock,
  input logic reset,
  input logic train,

  input logic arg_valid,
  input logic [N-1:0][7:0] arg_data,
  output logic arg_ready,

  output logic res_valid,
  output logic [7:0] res_data,
  input logic res_ready,

  input logic err_valid,
  input logic [15:0] err_data,
  output logic err_ready,

  output logic fbk_valid,
  output logic [N-1:0][15:0] fbk_data,
  input logic fbk_ready
);

  wire res_arg_valid;
  wire [15:0] res_arg_data;
  wire res_arg_ready;

  wire err_fbk_valid;
  wire [15:0] err_fbk_data;
  wire err_fbk_ready;

  associate #(.N(N), .RATE(0)) associator (
    .res_valid(res_arg_valid),
    .res_data(res_arg_data),
    .res_ready(res_arg_ready),
    .err_valid(err_fbk_valid),
    .err_data(err_fbk_data),
    .err_ready(err_fbk_ready),
    .*
  );

  heaviside activator (
    .arg_valid(res_arg_valid),
    .arg_data(res_arg_data),
    .arg_ready(res_arg_ready),
    .fbk_valid(err_fbk_valid),
    .fbk_data(err_fbk_data),
    .fbk_ready(err_fbk_ready),
    .*
  );

endmodule
