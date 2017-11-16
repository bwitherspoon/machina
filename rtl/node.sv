module node #(
  parameter WIDTH = 8,
  parameter DEPTH = 2,
  parameter SCALE = 1
)(
  input logic clock,
  input logic reset,
  input logic train,

  input  logic input_forward_valid,
  input  logic [DEPTH-1:0][WIDTH-1:0] input_forward_data,
  output logic input_forward_ready,

  input  logic input_backward_valid,
  input  logic [2*WIDTH-1:0] input_backward_data,
  output logic input_backward_ready,

  output logic output_backward_valid,
  output logic [DEPTH-1:0][2*WIDTH-1:0] output_backward_data,
  input  logic output_backward_ready,

  output logic output_forward_valid,
  output logic [WIDTH-1:0] output_forward_data,
  input  logic output_forward_ready
);

  typedef logic signed [WIDTH:0] standard_t;
  typedef logic signed [2*WIDTH-1:0] extended_t;

  standard_t weight [DEPTH];
  standard_t operand [DEPTH];

  extended_t summand;
  extended_t accumalater;
  extended_t delta;

  typedef logic [$clog2(DEPTH)-1:0] count_t;
  localparam CNT = count_t'(DEPTH - 1);
  count_t counter;

  enum logic [2:0] { RDY, MUL, MAC, ACC, FWD, DEL, BWD, UPD } state;

  // Initialize logistic activation function and its derivative
  // TODO We really only need [-6, 6] domain
  standard_t activation [2**(2*WIDTH)];
  standard_t activation_derivative [2**(2*WIDTH)];

  function real logistic(int value);
    return 1.0 / (1.0 + $exp(-1.0 * $itor(value) / 2.0**WIDTH));
  endfunction

  initial begin
    for (int i = -2**(2*WIDTH-1); i < 2**(2*WIDTH-1); i = i + 1) begin
      activation[i[2*WIDTH-1:0]] = standard_t'($rtoi(2**WIDTH * logistic(i)));
      activation_derivative[i[2*WIDTH-1:0]] = standard_t'($rtoi(2**WIDTH * logistic(i) * (1 - logistic(i))));
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
      if (counter == CNT) begin
        counter <= '0;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  // Multiply and accumalate input operands
  always @(posedge clock) begin
    if (state == MUL || state == MAC) begin
      summand <= (weight[counter] * operand[counter]) >>> WIDTH;
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
  assign input_forward_ready = state == RDY;

  genvar i;
  generate
    for (i = 0; i < DEPTH; i = i + 1) begin
      always @(posedge clock) begin
        if (input_forward_valid & input_forward_ready) begin
          operand[i] <= standard_t'(input_forward_data[i]);
        end
      end
    end
  endgenerate

  // Output activation on interface handshake when in forward pass state
  always @ (posedge clock) begin
    if (reset) begin
      output_forward_valid <= '0;
    end else if (state == FWD) begin
      if (!output_forward_valid | output_forward_ready) begin
        output_forward_valid <= '1;
        output_forward_data <= activation[$unsigned(accumalater)][WIDTH-1:0];
      end
    end else if (output_forward_valid & output_forward_ready) begin
        output_forward_valid <= '0;
    end
  end

  // Calculate delta on interface handshake when in delta state
  assign input_backward_ready = state == DEL;

  always @ (posedge clock) begin
    if (input_backward_valid & input_backward_ready) begin
      delta <= ($signed(input_backward_data) * activation_derivative[$unsigned(accumalater)]) >>> WIDTH;
    end
  end

  // Backward propagate errors and update weights when in the backward pass state
  // FIXME Use counter and single multiplier
  genvar j;
  generate
    for (j = 0; j < DEPTH; j = j + 1) begin
      always @(posedge clock) begin
        if (state == BWD) begin
          if (!output_backward_valid | output_backward_ready) begin
            output_backward_data[j] <= (weight[j] * delta) >>> WIDTH;
            weight[j] <= weight[j] + standard_t'((delta * operand[j]) >>> (SCALE + WIDTH));
          end
        end
      end
    end
  endgenerate

  always @ (posedge clock) begin
    if (reset) begin
      output_backward_valid <= '0;
    end else if (state == BWD) begin
      if (!output_backward_valid | output_backward_ready) begin
        output_backward_valid <= '1;
      end
    end else if (output_backward_valid & output_backward_ready) begin
        output_backward_valid <= '0;
    end
  end

  // State machine logic
  always @(posedge clock) begin
    if (reset) begin
      state <= RDY;
    end else begin
      case (state)
        RDY: begin
          if (input_forward_valid) begin
            state <= MUL;
          end
        end
        MUL: state <= MAC;
        MAC: begin
          if (counter == CNT) begin
            state <= ACC;
          end
        end
        ACC: state <= FWD;
        FWD: begin
          if (!output_forward_valid | output_forward_ready) begin
            if (train)
              state <= DEL;
            else
              state <= RDY;
          end
        end
        DEL: begin
          if (input_backward_valid) begin
            state <= BWD;
          end
        end
        BWD: begin
          if (!output_backward_valid | output_backward_ready) begin
            state <= RDY;
          end
        end
        default: $error("Invalid state");
      endcase
    end
  end

endmodule
