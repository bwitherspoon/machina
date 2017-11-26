module perceptron #(
  parameter N = 2
)(
  input clk,
  input rst,
  input en,

  input arg_stb,
  input [N-1:0][7:0] arg_dat,
  output arg_rdy,

  output res_stb,
  output [7:0] res_dat,
  input res_rdy,

  input err_stb,
  input [15:0] err_dat,
  output err_rdy,

  output fbk_stb,
  output [N-1:0][15:0] fbk_dat,
  input fbk_rdy
);

  wire res_arg_stb;
  wire [15:0] res_arg_dat;
  wire res_arg_rdy;

  wire err_fbk_stb;
  wire [15:0] err_fbk_dat;
  wire err_fbk_rdy;

  associate #(.N(N), .RATE(0)) associator (
    .res_stb(res_arg_stb),
    .res_dat(res_arg_dat),
    .res_rdy(res_arg_rdy),
    .err_stb(err_fbk_stb),
    .err_dat(err_fbk_dat),
    .err_rdy(err_fbk_rdy),
    .*
  );

  heaviside activator (
    .arg_stb(res_arg_stb),
    .arg_dat(res_arg_dat),
    .arg_rdy(res_arg_rdy),
    .fbk_stb(err_fbk_stb),
    .fbk_dat(err_fbk_dat),
    .fbk_rdy(err_fbk_rdy),
    .*
  );

endmodule
