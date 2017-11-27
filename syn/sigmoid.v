module sigmoid (
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
  localparam MUL = 3'd3;
  localparam FBK = 3'd4;
  reg [2:0] st = ARG;
  always @ (posedge clk) begin
    case (st)
      ARG: if (arg_ack) st <= RES;
      RES: if (res_ack) st <= (en) ? ERR : ARG;
      ERR: if (err_ack) st <= MUL;
      MUL: st <= FBK;
      FBK: if (fbk_ack) st <= ARG;
`ifdef SYNTHESIS
      default: st <= 3'bxxx;
`else
      default: begin
        $display("ERROR: invalid state: %d", st);
        $stop;
        st <= 3'bxxx;
      end
`endif
    endcase
  end

  // Internal argument register
  reg [15:0] arg;
  assign arg_rdy = st == ARG;
  always @ (posedge clk) begin
    if (arg_ack)
      arg <= arg_dat;
  end

  // Argument saturating comparators and multiplexer
  localparam ARG_MAX = +6 * 2**8;
  localparam ARG_MIN = -6 * 2**8;
  reg [11:0] act_adr;
  always @ (*) begin
    if ($signed(arg_dat) > ARG_MAX)
      act_adr = 12'h7ff;
    else if ($signed(arg_dat) < ARG_MIN)
      act_adr = 12'h800;
    else
      act_adr = arg[11:0];
  end

  // Activation function ROM
  wire act_en = st == RES && res_stb == 0;
  rom #(.WIDTH(8), .DEPTH(2**12), .FILENAME("sigmoid.dat")) act (
    .clk(clk),
    .rst(1'b0),
    .en(act_en),
    .adr(act_adr),
    .dat(res_dat)
  );

  // Activation function derivative ROM
  wire der_en = act_en & en;
  wire [5:0] der_dat;
  rom #(.WIDTH(6), .DEPTH(2**12), .FILENAME("sigmoid_derivative.dat")) der (
    .clk(clk),
    .rst(1'b0),
    .en(der_en),
    .adr(act_adr),
    .dat(der_dat)
  );

  // Result interface strobe
  always @ (posedge clk) begin
    if (st == RES) begin
      if (!res_stb)
        res_stb <= 1;
      else if (res_rdy)
        res_stb <= 0;
    end else begin
      res_stb <= 0;
    end
  end

  // Internal gradient register
  reg [5:0] grd = 0;
  always @ (posedge clk) begin
    if (res_ack & en)
      grd <= der_dat;
  end

  // Internal error register
  reg signed [15:0] err = 0;
  assign err_rdy = st == ERR;
  always @ (posedge clk) begin
    if (err_ack)
      err <= err_dat;
  end

  // Multiply error and gradient
  reg signed [21:0] prd = 0;
  always @ (posedge clk) begin
    if (st == MUL)
      prd = err * $signed({10'd0, grd});
  end

  // Feedback interface strobe and data
  wire signed [15:0] fbk = $signed({{2{prd[21]}}, prd[21:8]});
  always @ (posedge clk) begin
    if (st == FBK) begin
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
