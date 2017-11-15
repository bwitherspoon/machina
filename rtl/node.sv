module node #(
  parameter WIDTH /*verilator public*/ = 8,
  parameter DEPTH /*verilator public*/ = 2
)(
  input logic clock,
  input logic reset,

  input  logic                        input_valid,
  input  logic [DEPTH-1:0][WIDTH-1:0] input_data,
  output logic                        input_ready,

  // TODO
  // input  logic             backprop_valid,
  // input  logic [WIDTH-1:0] backprop_data,
  // output logic             backprop_ready,

  output logic             output_valid,
  output logic [WIDTH-1:0] output_data,
  input  logic             output_ready

  /// TODO
  // output logic             delta_valid,
  // output logic [WIDTH-1:0] delta_data,
  // input  logic             delta_ready
);
  typedef logic [WIDTH-1:0] data_t;
  typedef logic signed [WIDTH-1:0] operand_t;
  typedef logic signed [2*WIDTH-1:0] product_t;

  data_t activation [2**(2*WIDTH)];
  operand_t weight [DEPTH];
  operand_t operand [DEPTH];
  product_t summand;
  product_t accumalater;

  typedef logic [$clog2(DEPTH)-1:0] count_t;
  localparam COUNT = count_t'(DEPTH - 1);
  count_t counter;

  enum { IDLE, LOAD, WORK, LAST, DONE } state;

  // Initialize logistic activation function
  initial begin
    for (int i = -2**(2*WIDTH-1); i < 2**(2*WIDTH-1); i = i + 1) begin
      activation[i + 2**(2*WIDTH-1)] = data_t'($rtoi(2**WIDTH / (1 + $exp(-1 * $itor(i) / 2**(WIDTH-1)))));
    end
  end

  // Initialize weights
  initial begin
    for (int i = 0; i < DEPTH; i = i + 1) begin
      weight[i] = 0; //operand_t'($random % 2**($bits(weight[i])-1));
    end
  end

  assign input_ready = state == IDLE;

  genvar index;
  generate
    for (index = 0; index < DEPTH; index = index + 1) begin
      always @(posedge clock) begin
        if (input_valid & input_ready) begin
          operand[index] <= input_data[index];
        end
      end
    end
  endgenerate

  always @ (posedge clock) begin
    if (reset) begin
      output_valid <= '0;
    end else if (state == DONE) begin
      if (!output_valid | output_ready) begin
        output_valid <= '1;
        output_data <= activation[accumalater + 2**(2*WIDTH-1)];
      end
    end else begin
      if (output_valid & output_ready) begin
        output_valid <= '0;
      end
    end
  end

  always @(posedge clock) begin
    if (reset) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          if (input_valid) begin
            state <= LOAD;
          end
        end
        LOAD: state <= WORK;
        WORK: begin
          if (counter == COUNT) begin
            state <= LAST;
          end
        end
        LAST: state <= DONE;
        DONE: begin
          if (!output_valid | output_ready) begin
            state <= IDLE;
          end
        end
        default: $error("Invalid state");
      endcase
    end
  end

  always @(posedge clock) begin
    if (reset) begin
      counter <= '0;
    end else if (state == LOAD || state == WORK) begin
      if (counter == COUNT) begin
        counter <= '0;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  always @(posedge clock) begin
    if (state == LOAD || state == WORK) begin
      summand <= (weight[counter] * operand[counter]) >>> (WIDTH - 1);
    end
  end

  always @(posedge clock) begin
    if (reset) begin
      accumalater <= '0;
    end else if (state == IDLE) begin
      accumalater <= '0;
    end else if (state == WORK || state == LAST) begin
      accumalater <= accumalater + summand;
    end
  end

endmodule
