module associate #(
  parameter ARGN = 2,
  parameter RATE = 2
)(
  input clk,
  input rst,
  input en,

  input arg_stb,
  input [8*ARGN-1:0] arg_dat,
  output arg_rdy,

  output reg res_stb,
  output reg [15:0] res_dat,
  input res_rdy,

  input err_stb,
  input [15:0] err_dat,
  output err_rdy,

  output reg fbk_stb,
  output reg [16*ARGN-1:0] fbk_dat,
  input fbk_rdy
);
  localparam MAX = 24'sh007fff;
  localparam MIN = 24'shff8000;

  wire arg_ack = arg_stb & arg_rdy;
  wire res_ack = res_stb & res_rdy;
  wire err_ack = err_stb & err_rdy;
  wire fbk_ack = fbk_stb & fbk_rdy;

  reg signed [8:0] args [0:ARGN-1];
  reg signed [15:0] weights [0:ARGN-1];
  reg signed [15:0] bias = 0;
  reg signed [15:0] delta = 0;

  localparam ARG = 4'd0;
  localparam MUL = 4'd1;
  localparam MAC = 4'd2;
  localparam ACC = 4'd3;
  localparam RES = 4'd4;
  localparam DEL = 4'd5;
  localparam ERR = 4'd6;
  localparam FBK = 4'd7;
  localparam UPD = 4'd8;
  reg [3:0] state = ARG;

  // Cycle counter
  localparam END = ARGN - 1;
  reg [$clog2(ARGN)-1:0] cnt = 0;
  wire cnt_ini = cnt == 0;
  wire cnt_end = cnt == END[$clog2(ARGN)-1:0];
  wire cnt_stb = state == MUL || state == MAC || state == ERR || state == UPD;
  always @(posedge clk) cnt <= cnt_stb & ~cnt_end ? cnt + 1 : 0;

  // State register and logic
  always @(posedge clk) begin
    if (rst) begin
      state <= ARG;
    end else begin
      case (state)
        ARG: if (arg_stb) state <= MUL;
        MUL: state <= MAC;
        MAC: if (cnt_end) state <= ACC;
        ACC: state <= RES;
        RES: if (res_ack) state <= (en) ? DEL : ARG;
        DEL: if (err_stb) state <= ERR;
        ERR: if (cnt_end) state <= FBK;
        FBK: if (fbk_ack) state <= UPD;
        UPD: if (cnt_end) state <= ARG;
`ifdef SYNTHESIS
        default state <= 4'bxxxx;
`else
        default: begin
          $display("ERROR: %s:%0d invalid state: %0d", `__FILE__, `__LINE__, state);
          $stop;
          state <= 4'bxxxx;
        end
`endif
      endcase
    end
  end

  // Initialize weights to zero
`ifndef SYNTHESIS
  integer n;
  initial begin
    for (n = 0; n < ARGN; n = n + 1)
      weights[n] = 0;
  end
`endif

  // Load arguments
  assign arg_rdy = state == ARG;

  genvar m;
  generate
    for (m = 0; m < ARGN; m = m + 1)
      always @ (posedge clk)
        if (arg_ack)
          args[m] <= {1'b0, arg_dat[8*m +: 8]};
  endgenerate

  // Multiply and accumulate (MAC)
  reg signed [23:0] mul = 0;
  reg signed [23:0] acc = 0;
  wire signed [23:0] sum = acc + mul;

  always @ (posedge clk) begin
    if (state == MUL || state == MAC) begin
      mul <= weights[cnt] * args[cnt] >>> 8;
    end
  end

  always @ (posedge clk) begin
    if (state == ARG) begin
      /* verilator lint_off WIDTH */
      acc <= bias;
      /* verilator lint_on WIDTH */
    end else if (state == MAC || state == ACC) begin
      case ({MIN <= sum, sum <= MAX})
        2'b11: acc <= sum;
        2'b10: acc <= MAX;
        2'b01: acc <= MIN;
        2'b00: acc <= 24'hxxxxxx;
      endcase
    end
  end

  // Output inner product
  initial res_stb = 0;

  always @ (posedge clk) begin
    if (state == RES) begin
      if (!res_stb) begin
        res_stb <= 1;
        res_dat <= acc[15:0];
      end else if (res_rdy) begin
        res_stb <= 0;
      end
    end else begin
      res_stb <= 0;
    end
  end

  // Load delta
  assign err_rdy = state == DEL;

  always @ (posedge clk) begin
    if (err_ack) begin
      delta <= $signed(err_dat);
    end
  end

  // Evaluate and saturate errors
  reg [15:0] fbk [0:ARGN-1];
  wire signed [23:0] err = weights[cnt] * delta >>> 8;

  always @ (posedge clk) begin
    if (state == ERR) begin
      case ({MIN <= err, err <= MAX})
        2'b11: fbk[cnt] <= err[15:0];
        2'b10: fbk[cnt] <= MAX[15:0];
        2'b01: fbk[cnt] <= MIN[15:0];
        2'b00: fbk[cnt] <= 16'hxxxx;
      endcase
    end
  end

  // Backward propagate errors
  initial fbk_stb = 0;
  always @ (posedge clk) begin
    if (state == FBK) begin
      if (!fbk_stb)
        fbk_stb <= 1;
      else if (fbk_rdy)
        fbk_stb <= 0;
    end else begin
      fbk_stb <= 0;
    end
  end

  genvar k;
  generate
    for (k = 0; k < ARGN; k = k + 1)
      always @ (posedge clk) begin
        if (state == FBK) begin
          fbk_dat[16*k +: 16] <= fbk[k];
        end
      end
  endgenerate

  // Update weights and bias
  wire signed [23:0] prod = delta * args[cnt];
  /* verilator lint_off WIDTH */
  wire signed [23:0] next = weights[cnt] + (prod >>> 8 + RATE);
  /* verilator lint_on WIDTH */
  integer j;
  always @ (posedge clk) begin
    if (rst) begin
      for (j = 0; j < ARGN; j = j + 1) begin
        weights[j] <= 0;
      end
    end else if (state == UPD) begin
      case ({MIN <= next, next <= MAX})
        2'b11: weights[cnt] <= next[15:0];
        2'b10: weights[cnt] <= MAX[15:0];
        2'b01: weights[cnt] <= MIN[15:0];
        2'b00: weights[cnt] <= 16'hxxxx;
      endcase
    end
  end

  always @ (posedge clk) begin
    if (rst) begin
      bias <= 0;
    end else if (state == UPD && cnt_ini) begin
      bias <= bias + (delta >>> RATE);
    end
  end

endmodule
