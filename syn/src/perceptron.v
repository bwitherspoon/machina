module perceptron #(
  parameter ARGN = 2
)(
  input clk,
  input rst,
  input en,

  input arg_stb,
  input [ARGN-1:0][7:0] arg_dat,
  output arg_rdy,

  output res_stb,
  output [7:0] res_dat,
  input res_rdy,

  input err_stb,
  input [15:0] err_dat,
  output err_rdy,

  output fbk_stb,
  output [ARGN-1:0][15:0] fbk_dat,
  input fbk_rdy
);
  wire ass_res_to_act_arg_stb;
  wire [15:0] ass_res_to_act_arg_dat;
  wire ass_res_to_act_arg_rdy;
  wire ass_err_to_act_fbk_stb;
  wire [15:0] ass_err_to_act_fbk_dat;
  wire ass_err_to_act_fbk_rdy;

  associate #(.ARGN(ARGN), .RATE(1)) associator (
    .clk(clk),
    .rst(rst),
    .en(en),
    .arg_stb(arg_stb),
    .arg_dat(arg_dat),
    .arg_rdy(arg_rdy),
    .res_stb(ass_res_to_act_arg_stb),
    .res_dat(ass_res_to_act_arg_dat),
    .res_rdy(ass_res_to_act_arg_rdy),
    .err_stb(ass_err_to_act_fbk_stb),
    .err_dat(ass_err_to_act_fbk_dat),
    .err_rdy(ass_err_to_act_fbk_rdy),
    .fbk_stb(fbk_stb),
    .fbk_dat(fbk_dat),
    .fbk_rdy(fbk_rdy)
  );
  heaviside activator (
    .clk(clk),
    .rst(rst),
    .en(en),
    .arg_stb(ass_res_to_act_arg_stb),
    .arg_dat(ass_res_to_act_arg_dat),
    .arg_rdy(ass_res_to_act_arg_rdy),
    .res_stb(res_stb),
    .res_dat(res_dat),
    .res_rdy(res_rdy),
    .err_stb(err_stb),
    .err_dat(err_dat),
    .err_rdy(err_rdy),
    .fbk_stb(ass_err_to_act_fbk_stb),
    .fbk_dat(ass_err_to_act_fbk_dat),
    .fbk_rdy(ass_err_to_act_fbk_rdy)
  );

endmodule
