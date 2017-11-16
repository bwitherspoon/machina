module node #(
  parameter WIDTH = 8,
  parameter DEPTH = 2,
  parameter SCALE = 0
)(
  input logic clock,
  input logic reset,
  input logic train,

  input  logic                        input_valid,
  input  logic [DEPTH-1:0][WIDTH-1:0] input_data,
  output logic                        input_ready,

  output logic                          output_backprop_valid,
  output logic [DEPTH-1:0][2*WIDTH-1:0] output_backprop_data,
  input  logic                          output_backprop_ready,

  input  logic               input_backprop_valid,
  input  logic [2*WIDTH-1:0] input_backprop_data,
  output logic               input_backprop_ready,

  output logic             output_valid,
  output logic [WIDTH-1:0] output_data,
  input  logic             output_ready
);
  typedef logic signed [WIDTH-1:0]   operand_t;
  typedef logic signed [2*WIDTH-1:0] product_t;

  operand_t weight [DEPTH];
  operand_t operand [DEPTH];

  product_t summand;
  product_t accumalater;
  product_t delta;

  typedef logic [$clog2(DEPTH)-1:0] count_t;
  localparam COUNT = count_t'(DEPTH - 1);
  count_t counter;

  enum logic [2:0] { RDY, MUL, MAC, ACC, FWD, DEL, BWD, UPD } state;

  // Initialize logistic activation function and its derivative
  // TODO We really only need [-6, 6] domain
  operand_t activation [2**(2*WIDTH)];
  operand_t activation_derivative [2**(2*WIDTH)];

  function real logistic(int value);
    // Returns real in [0, 1] range
    return 1.0 / (1.0 + $exp(-1.0 * $itor(value) / 2.0**(WIDTH-1)));
  endfunction

  initial begin
    for (int i = -2**(2*WIDTH-1); i < 2**(2*WIDTH-1); i = i + 1) begin
      // Range [0, 127] -> [0, 1]
      activation[i[2*WIDTH-1:0]] = operand_t'($rtoi(2**(WIDTH-1) * logistic(i)));
      // Range [0, 63] -> [0, 0.25]
      activation_derivative[i[2*WIDTH-1:0]] = operand_t'($rtoi(2**(WIDTH-1) * logistic(i) * (1 - logistic(i))));
    end
  end

  // Initialize weights
  // TODO Should be initialized uniformly random
  initial begin
    for (int i = 0; i < DEPTH; i = i + 1) begin
      weight[i] = 0;
    end
  end

  // Count multiply and accumalate cycles
  always @(posedge clock) begin
    if (reset) begin
      counter <= '0;
    end else if (state == MUL || state == MAC) begin
      if (counter == COUNT) begin
        counter <= '0;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  // Multiply and accumalate input operands
  always @(posedge clock) begin
    if (state == MUL || state == MAC) begin
      summand <= (weight[counter] * operand[counter]) >>> (WIDTH - 1);
    end
  end

  always @(posedge clock) begin
    if (reset) begin
      accumalater <= '0;
    end else if (state == RDY) begin
      accumalater <= '0;
    end else if (state == MAC || state == ACC) begin
      accumalater <= accumalater + summand;
    end
  end

  // Load input on interface handshake when in ready state
  assign input_ready = state == RDY;

  genvar i;
  generate
    for (i = 0; i < DEPTH; i = i + 1) begin
      always @(posedge clock) begin
        if (input_valid & input_ready) begin
          operand[i] <= input_data[i];
        end
      end
    end
  endgenerate

  // Output activation on interface handshake when in forward pass state
  always @ (posedge clock) begin
    if (reset) begin
      output_valid <= '0;
    end else if (state == FWD) begin
      if (!output_valid | output_ready) begin
        output_valid <= '1;
        output_data <= activation[$unsigned(accumalater)];
      end
    end else if (output_valid & output_ready) begin
        output_valid <= '0;
    end
  end

  // Calculate delta on interface handshake when in delta state
  assign input_backprop_ready = state == DEL;

  always @ (posedge clock) begin
    if (input_backprop_valid & input_backprop_ready) begin
      delta <= ($signed(input_backprop_data) * product_t'(activation_derivative[$unsigned(accumalater)])) >>> (WIDTH - 1);
    end
  end

  // Backward propagate errors and update weights when in the backward pass state
  // FIXME Use counter and single multiplier
  genvar o;
  generate
    for (o = 0; o < DEPTH; o = o + 1) begin
      always @(posedge clock) begin
        if (state == BWD) begin
          if (!output_backprop_valid | output_backprop_ready) begin
            output_backprop_data[o] <= (weight[o] * delta) >>> (WIDTH - 1);
            weight[o] <= weight[o] + operand_t'(((delta * operand[o]) >>> (SCALE + WIDTH - 1)));
          end
        end
      end
    end
  endgenerate

  always @ (posedge clock) begin
    if (reset) begin
      output_backprop_valid <= '0;
    end else if (state == BWD) begin
      if (!output_backprop_valid | output_backprop_ready) begin
        output_backprop_valid <= '1;
      end
    end else if (output_valid & output_ready) begin
        output_backprop_valid <= '0;
    end
  end

  // State machine logic
  always @(posedge clock) begin
    if (reset) begin
      state <= RDY;
    end else begin
      case (state)
        RDY: begin
          if (input_valid) begin
            state <= MUL;
          end
        end
        MUL: state <= MAC;
        MAC: begin
          if (counter == COUNT) begin
            state <= ACC;
          end
        end
        ACC: state <= FWD;
        FWD: begin
          if (!output_valid | output_ready) begin
            if (train)
              state <= DEL;
            else
              state <= RDY;
          end
        end
        DEL: begin
          if (input_backprop_valid) begin
            state <= BWD;
          end
        end
        BWD: begin
          if (!output_backprop_valid | output_backprop_ready) begin
            state <= RDY;
          end
        end
        default: $error("Invalid state");
      endcase
    end
  end

endmodule
