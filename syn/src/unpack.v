module unpack #(
  parameter ARGW = 8,
  parameter ARGD = 2
)(
  input clk,
  input rst,

  input arg_stb,
  input [ARGD*ARGW-1:0] arg_dat,
  output arg_rdy,

  output reg out_stb,
  output reg [ARGW-1:0] out_dat,
  input out_rdy
);
  localparam [$clog2(ARGD)-1:0] END = ARGD[$clog2(ARGD)-1:0] - 1;

  reg [$clog2(ARGD)-1:0] idx = 0;

  initial out_stb = 0;

  assign arg_rdy = idx == END & out_rdy;

  always @(posedge clk) begin
    if (rst | idx == END) begin
      idx <= 0;
    end else if ((idx == 0 & arg_stb) | (idx != 0 & out_stb & out_rdy)) begin
      idx <= idx + 1;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      out_stb <= 0;
    end else if (idx == 0) begin
      if (arg_stb)
        out_stb <= 1;
      else if (out_stb & out_rdy)
        out_stb <= 0;
    end
  end

  always @(posedge clk) begin
    if ((idx == 0 & arg_stb) | (idx != 0 & out_stb & out_rdy))
      out_dat <= arg_dat[ARGW*idx+:ARGW];
  end

endmodule
