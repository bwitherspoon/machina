module memory #(
  parameter WIDTH = 16,
  parameter DEPTH = 256,
  parameter INIT = ""
)(
  input clk,
  input rst,
  // Write address
  input waddr_stb,
  input [$clog2(DEPTH)-1:0] waddr_dat,
  output waddr_rdy,
  // Write data
  input wdata_stb,
  input [WIDTH-1:0] wdata_dat,
  output wdata_rdy,
  // Read address
  input raddr_stb,
  input [$clog2(DEPTH)-1:0] raddr_dat,
  output raddr_rdy,
  // Read data
  input rdata_rdy,
  output reg rdata_stb,
  output reg [WIDTH-1:0] rdata_dat
);
  reg [WIDTH-1:0] mem [0:DEPTH-1];

  if (INIT != "") initial $readmemh(INIT, mem, 0, DEPTH-1);

  initial rdata_stb = 0;

  assign waddr_rdy = waddr_stb & wdata_stb & ~(raddr_stb & raddr_dat == waddr_dat);
  assign wdata_rdy = waddr_rdy;
  assign raddr_rdy = ~rdata_stb | rdata_rdy;

  always @(posedge clk) begin
    if (rst) begin
      rdata_stb <= 0;
    end else if (raddr_stb & raddr_rdy) begin
      rdata_stb <= 1;
      rdata_dat <= mem[raddr_dat];
    end else if (rdata_stb & rdata_rdy) begin
      rdata_stb <= 0;
    end
  end

  always @(posedge clk) begin
    if (waddr_stb & wdata_stb) begin
      mem[waddr_dat] <= wdata_dat;
    end
  end

endmodule
