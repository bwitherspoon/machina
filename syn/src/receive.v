module receive #(
  parameter integer BAUD = 9600,
  parameter integer FREQ = 12000000
)(
  input clk,
  input rst,
  input rxd,
  input rdy,
  output reg stb,
  output reg [7:0] dat
);
  localparam integer PERIOD = FREQ / BAUD;
  localparam COUNT = PERIOD[$clog2(3*PERIOD/2)-1:0];
  localparam [3:0] IDLE = 0;
  localparam [3:0] START = 1;
  localparam [3:0] STOP = 10;

  reg [$clog2(3*PERIOD/2)-1:0] count = 0;
  reg [3:0] state = IDLE;
  reg [7:0] data;

  initial stb = 0;
  always @(posedge clk) begin
    if (rst) begin
      stb <= 0;
    end else if (state == STOP) begin
      if (~stb | rdy) begin
        stb <= 1;
        dat <= data;
      end
    end else if (stb & rdy) begin
      stb <= 0;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
      count <= 0;
    end else begin
      case (state)
      IDLE:
        if (~rxd) begin
          state <= START;
          count <= COUNT >> 1;
        end
      STOP:
        if (~stb | rdy) begin
          state <= IDLE;
        end
      default:
        if (count == COUNT) begin
          data <= {rxd, data[7:1]};
          state <= state + 1;
          count <= 0;
        end else begin
          count <= count + 1;
        end
      endcase
    end
  end

endmodule
