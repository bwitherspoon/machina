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
  localparam integer CYCLES = FREQ / BAUD;
  localparam COUNT_WIDTH = $clog2(3*CYCLES/2);
  localparam COUNT = CYCLES[COUNT_WIDTH-1:0];

  localparam START = 0;
  localparam VALID = 10;

  reg [COUNT_WIDTH-1:0] count = 0;
  reg [3:0] state = START;
  reg [7:0] data;

  initial stb = 0;
  always @(posedge clk) begin
    if (rst) begin
      stb <= 0;
    end else if (state == VALID) begin
      if (~stb) begin
        stb <= 1;
        dat <= data;
      end else if (rdy) begin
        stb <= 0;
      end
    end else if (stb & rdy) begin
      stb <= 0;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      count <= 0;
      state <= START;
    end else if (state == START) begin
      if (!rxd) begin
        count <= COUNT >> 1;
        state <= 1;
      end
    end else begin
      if (count != COUNT) begin
        count <= count + 1;
      end else begin
        if (state == VALID) begin
          if (~stb | rdy) begin
            count <= 0;
            state <= 0;
          end
        end else begin
          count <= 0;
          state <= state + 1;
          data <= {rxd, data[7:1]};
        end
      end
    end
  end

endmodule
