module sigmoid #(
  parameter ACTIV = "gen/dat/sigmoid_activ.dat",
  parameter DERIV = "gen/dat/sigmoid_deriv.dat"
)(
  input clk,
  input rst,
  input en,

  input arg_stb,
  input [15:0] arg_dat,
  output arg_rdy,

  output reg res_stb,
  output [7:0] res_dat,
  input res_rdy,

  input err_stb,
  input [15:0] err_dat,
  output err_rdy,

  output reg fbk_stb,
  output reg [15:0] fbk_dat,
  input fbk_rdy
);
  // Interface acknowledge signals
  wire arg_ack = arg_stb & arg_rdy;
  wire res_ack = res_stb & res_rdy;
  wire err_ack = err_stb & err_rdy;
  wire fbk_ack = fbk_stb & fbk_rdy;

  // State register and next state logic
  localparam ARG = 3'd0;
  localparam RES = 3'd1;
  localparam ERR = 3'd2;
  localparam DEL = 3'd3;
  localparam FBK = 3'd4;
  reg [2:0] state = ARG;
  always @ (posedge clk) begin
    if (rst)
      state <= ARG;
    else
      case (state)
        ARG: if (arg_stb) state <= RES;
        RES: if (res_ack) state <= (en) ? ERR : ARG;
        ERR: if (err_stb) state <= DEL;
        DEL: state <= FBK;
        FBK: if (fbk_ack) state <= ARG;
`ifdef SYNTHESIS
        default: state <= 3'bxxx;
`else
        default: begin
          $display("ERROR: invalid state: %d", state);
          $stop;
          state <= 3'bxxx;
        end
`endif
      endcase
  end

  // Internal argument register
  reg signed [15:0] arg;
  assign arg_rdy = state == ARG;
  always @ (posedge clk) begin
    if (arg_ack)
      arg <= arg_dat;
  end

  // Argument saturating comparators and multiplexer
  localparam ARG_MAX = 16'sh07ff;
  localparam ARG_MIN = 16'shf800;
  reg [11:0] act_adr;
  always @ (*) begin
    case ({ARG_MIN <= arg, arg <= ARG_MAX})
      2'b11: act_adr = arg[11:0];
      2'b10: act_adr = ARG_MAX[11:0];
      2'b01: act_adr = ARG_MIN[11:0];
      2'b00: act_adr = 12'hxxx;
    endcase
  end

  // Activation function ROM
  wire act_en = state == RES && res_stb == 0;
  rom #(.WIDTH(8), .DEPTH(2**12), .DATA(ACTIV)) activ (
    .clk(clk),
    .rst(1'b0),
    .en(act_en),
    .adr(act_adr),
    .dat(res_dat)
  );

  // Activation function derivative ROM
  wire [6:0] der_dat;
  rom #(.WIDTH(7), .DEPTH(2**12), .DATA(DERIV)) deriv (
    .clk(clk),
    .rst(1'b0),
    .en(act_en),
    .adr(act_adr),
    .dat(der_dat)
  );

  // Result interface strobe
  initial res_stb = 0;
  always @ (posedge clk) begin
    if (state == RES) begin
      if (!res_stb)
        res_stb <= 1;
      else if (res_rdy)
        res_stb <= 0;
    end else begin
      res_stb <= 0;
    end
  end

  // Internal gradient register
  reg [6:0] der = 0;
  always @ (posedge clk) begin
    if (res_ack)
      der <= der_dat;
  end

  // Internal error register
  reg signed [15:0] err = 0;
  assign err_rdy = state == ERR;
  always @ (posedge clk) begin
    if (err_ack)
      err <= err_dat;
  end

  // Multiply error and gradient
  // (-2^21 <= del < 2^21) = (0 <= der <= 2^6) * (-2^15 <= err < 2^15)
  reg signed [21:0] del = 0;
  always @ (posedge clk) begin
    if (state == DEL)
      del <= err * $signed({15'd0, der});
  end

  // Feedback interface strobe and data
  wire [7:0] unused = del[7:0];
  wire [15:0] fbk = {{2{del[21]}}, del[21:8]};
  initial fbk_stb = 0;
  always @ (posedge clk) begin
    if (state == FBK) begin
      if (!fbk_stb) begin
        fbk_stb <= 1;
        fbk_dat <= fbk;
      end else if (fbk_rdy) begin
        fbk_stb <= 0;
      end
    end else begin
      fbk_stb <= 0;
    end
  end

endmodule
