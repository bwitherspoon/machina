module demultiplex #(
  parameter ARGW = 16,
  parameter OUTC = 2
)(
  input clk,
  input rst,

  input arg_stb,
  input [ARGW-1:0] arg_dat,
  output arg_rdy,

  input sel_stb,
  input [$clog2(OUTC)-1:0] sel_dat,
  output sel_rdy,

  output reg [OUTC-1:0] out_stb,
  output reg [OUTC*ARGW-1:0] out_dat,
  input [OUTC-1:0] out_rdy
);
  wire arg_ack = arg_stb & arg_rdy;
  wire sel_ack = sel_stb & sel_rdy;
  wire [OUTC-1:0] out_bsy = out_stb & ~out_rdy;

  assign arg_rdy = arg_stb & sel_stb & ~out_bsy[sel_dat];
  assign sel_rdy = arg_rdy;

  initial out_stb = {OUTC{1'b0}};

  always @(posedge clk) begin
    if (rst) begin
      out_stb <= {OUTC{1'b0}};
    end else if (out_stb[sel_dat]) begin
      if (out_rdy[sel_dat]) begin
        if (arg_ack & sel_ack)
          out_dat[ARGW*sel_dat+:ARGW] <= arg_dat;
        else
          out_stb[sel_dat] <= 0;
      end
    end else if (arg_ack & sel_ack) begin
        out_stb[sel_dat] <= 1;
        out_dat[ARGW*sel_dat+:ARGW] <= arg_dat;
    end
  end

endmodule
