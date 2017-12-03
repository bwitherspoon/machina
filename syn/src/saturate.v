module saturate #(
  parameter ARGW = 16,
  parameter RESW = ARGW
)(
  input clk,
  input rst,

  input arg_stb,
  input [ARGW-1:0] arg_dat,
  output arg_rdy,

  output reg res_stb,
  output reg [RESW-1:0] res_dat,
  input res_rdy
);
  initial if (RESW > ARGW)
    $display("ERROR: saturate: result width should be less then or equal to argument width");

  localparam MAX = 2**(RESW-1);
  localparam MIN = -MAX;
  localparam max = $signed(MAX[ARGW:0]);
  localparam min = $signed(MIN[ARGW:0]);
  wire signed [ARGW:0] cmp = {arg_dat[ARGW-1], arg_dat};
  reg signed [RESW-1:0] sat;

  always @* begin
    case ({min < cmp, cmp < max})
      2'b11: sat = arg_dat[0+:RESW];
      2'b10: sat = MAX - 1;
      2'b01: sat = MIN;
      2'b00: sat = {RESW{1'bx}};
    endcase
  end

  assign arg_rdy = ~res_stb | res_rdy;

  initial res_stb = 0;
  always @(posedge clk) begin
    if (rst) begin
      res_stb <= 0;
    end else if (!res_stb) begin
      if (arg_stb) begin
        res_stb <= 1;
        res_dat <= sat;
      end
    end else if (res_rdy) begin
      res_stb <= 0;
    end
  end

 endmodule
