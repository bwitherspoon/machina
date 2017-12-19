module multiplex #(
  parameter ARGW = 16,
  parameter ARGC = 2
)(
  input clk,
  input rst,

  input [ARGC-1:0] arg_stb,
  input [ARGC*ARGW-1:0] arg_dat,
  output reg [ARGC-1:0] arg_rdy,

  input sel_stb,
  input [$clog2(ARGC)-1:0] sel_dat,
  output sel_rdy,

  output reg out_stb,
  output reg [ARGW-1:0] out_dat,
  input out_rdy
);
  wire [ARGC-1:0] arg_ack = arg_stb & arg_rdy;
  wire sel_ack = sel_stb & sel_rdy;

  initial out_stb = 0;

  always @* begin
    arg_rdy = {ARGC{1'b0}};
    if (sel_stb & arg_stb[sel_dat])
      arg_rdy[sel_dat] = ~out_stb | out_rdy;
  end

  assign sel_rdy = sel_stb & arg_stb[sel_dat] & arg_rdy[sel_dat];

  always @(posedge clk) begin
    if (rst) begin
      out_stb <= 0;
    end else if (out_stb) begin
      if (out_rdy) begin
        if (sel_ack & arg_ack[sel_dat])
          out_dat <= arg_dat[ARGW*sel_dat+:ARGW];
        else
          out_stb <= 0;
      end
    end else if (sel_ack & arg_ack[sel_dat]) begin
      out_stb <= 1;
      out_dat <= arg_dat[ARGW*sel_dat+:ARGW];
    end
  end

endmodule
