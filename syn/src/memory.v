module memory #(
  parameter WIDTH = 16,
  parameter DEPTH = 256,
  parameter INIT = ""
)(
  input clk,
  input rst,
  // Write address slave
  input aw_stb,
  input [$clog2(DEPTH)-1:0] aw_dat,
  output aw_rdy,
  // Read address slave
  input ar_stb,
  input [$clog2(DEPTH)-1:0] ar_dat,
  output ar_rdy,
  // Write data slave
  input w_stb,
  input [WIDTH-1:0] w_dat,
  output w_rdy,
  // Read data master
  input r_rdy,
  output reg r_stb,
  output reg [WIDTH-1:0] r_dat
);
  reg [WIDTH-1:0] mem [0:DEPTH-1];

  if (INIT != "") initial $readmemh(INIT, mem, 0, DEPTH-1);

  initial r_stb = 0;

  assign aw_rdy = aw_stb & w_stb & ~(ar_stb & ar_dat == aw_dat);
  assign w_rdy = aw_rdy;
  assign ar_rdy = ~r_stb | r_rdy;

  always @(posedge clk) begin
    if (rst) begin
      r_stb <= 0;
    end else if (ar_stb & ar_rdy) begin
      r_stb <= 1;
      r_dat <= mem[ar_dat];
    end else if (r_stb & r_rdy) begin
      r_stb <= 0;
    end
  end

  always @(posedge clk) begin
    if (aw_stb & w_stb) begin
      mem[aw_dat] <= w_dat;
    end
  end

endmodule
