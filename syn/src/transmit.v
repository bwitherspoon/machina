module transmit #(
  parameter integer FREQ = 12000000,
  parameter integer BAUD = 9600
)(
  input clk,
  input rst,
  input stb,
  input [7:0] dat,
  output rdy,
  output txd
);
  localparam integer PERIOD = FREQ / BAUD;
  localparam CNT = PERIOD[$clog2(PERIOD)-1:0];

  reg [$clog2(PERIOD)-1:0] cnt = 0;
  reg [3:0] idx = 0;
  reg [7:0] tmp;

  reg rdy = 1;
  reg txd = 1;

  always @ (posedge clk) begin
    if (rst) begin
      rdy <= 1;
    end else if (rdy) begin
      if (stb) begin
        rdy <= 0;
        txd <= 0;
        tmp <= dat;
      end
    end else begin
      if (cnt == CNT) begin
        if (idx == 9) begin
          rdy <= 1;
          txd <= 1;
          idx <= 0;
        end else begin
          txd <= idx == 8 ? 1 : tmp[idx];
          idx <= idx + 1;
        end
        cnt <= 0;
      end else begin
        cnt <= cnt + 1;
      end
    end
  end

endmodule
