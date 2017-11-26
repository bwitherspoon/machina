module heaviside (
  input clk,
  input rst,
  input en,

  input arg_stb,
  input [15:0] arg_dat,
  output arg_rdy,

  output reg res_stb,
  output reg [7:0] res_dat,
  input res_rdy,

  input err_stb,
  input [15:0] err_dat,
  output err_rdy,

  output reg fbk_stb,
  output reg [15:0] fbk_dat,
  input fbk_rdy
);

  wire arg_ack = arg_stb & arg_rdy;
  wire res_ack = res_stb & res_rdy;
  wire err_ack = err_stb & err_rdy;
  wire fbk_ack = fbk_stb & fbk_rdy;

  reg signed [15:0] arg;
  reg [15:0] err;

  localparam ARG = 2'd0;
  localparam RES = 2'd1;
  localparam ERR = 2'd2;
  localparam FBK = 2'd3;
  reg [1:0] st = ARG;

  always @ (posedge clk) begin
    if (rst)
      st <= ARG;
    else
      case (st)
        ARG: if (arg_ack) st <= RES;
        RES: if (res_ack) st <= (en) ? ERR : ARG;
        ERR: if (err_ack) st <= FBK;
        FBK: if (fbk_ack) st <= ARG;
      endcase
  end

  // Internal argument register
  assign arg_rdy = st == ARG;
  always @ (posedge clk) begin
    if (arg_stb & arg_rdy)
      arg <= arg_dat;
  end

  // Result interface strobe and data
  always @ (posedge clk) begin
    if (st == RES) begin
      if (!res_stb) begin
        res_stb <= 1;
        res_dat <= (arg < 0) ? 8'h00 : 8'hff;
      end else if (res_rdy) begin
        res_stb <= 0;
      end
    end else begin
      res_stb <= 0;
    end
  end

  // Internal error register
  assign err_rdy = st == ERR;
  always @ (posedge clk) begin
    if (err_stb & err_rdy)
      err <= err_dat;
  end

  always @ (posedge clk) begin
    if (st == FBK) begin
      if (!fbk_stb) begin
        fbk_stb <= 1;
        fbk_dat <= err;
      end else if (fbk_rdy) begin
        fbk_stb <= 0;
      end
    end else begin
      fbk_stb <= 0;
    end
  end

endmodule
