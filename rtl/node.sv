module node #(
  parameter N = 2,
  parameter K = 2
)(
  input logic clock,
  input logic reset,
  input logic train,

  input  logic input_forward_valid,
  input  logic [N-1:0][7:0] input_forward_data,
  output logic input_forward_ready,

  input  logic input_backward_valid,
  input  logic [15:0] input_backward_data,
  output logic input_backward_ready,

  output logic output_backward_valid,
  output logic [N-1:0][15:0] output_backward_data,
  input  logic output_backward_ready,

  output logic output_forward_valid,
  output logic [7:0] output_forward_data,
  input  logic output_forward_ready
);

  localparam W = 8;
  typedef logic signed [W:0] standard_t;
  typedef logic signed [2*$bits(standard_t)-1:0] extended_t;

  typedef logic [$clog2(N)-1:0] counter_t;
  localparam CNT = counter_t'(N - 1);
  counter_t counter;

  standard_t operand [N];
  extended_t weight [N];
  extended_t bias;
  extended_t summand;
  extended_t accumulator;
  extended_t delta;

  enum logic [2:0] { RDY, MUL, MAC, ACC, FWD, DEL, BWD, UPD } state;

  // Initialize logistic activation function and its derivative
  // TODO We really only need [-6, 6] domain
  standard_t activation [2**(2*W)];
  standard_t activation_derivative [2**(2*W)];

  function real logistic(int value, real rate = 6.0);
    return 1.0 / (1.0 + $exp(-rate * $itor(value) / 2.0**W));
  endfunction

  initial begin
    for (int i = -2**(2*W-1); i < 2**(2*W-1); i = i + 1) begin
      activation[i[2*W-1:0]] = standard_t'($rtoi(2**W * logistic(i)));
      activation_derivative[i[2*W-1:0]] = standard_t'($rtoi(2**W * logistic(i) * (1 - logistic(i))));
    end
  end

  // Initialize weights
  // TODO Should be initialized uniformly random
  initial begin
    bias = 0;
    for (int i = 0; i < N; i = i + 1) begin
      weight[i] = extended_t'($random % 16);
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
      summand <= (weight[counter] * operand[counter]) >>> W;
    end
  end

  always @(posedge clock) begin
    if (reset) begin
      accumulator <= '0;
    end else if (state == RDY) begin
      accumulator <= bias;
    end else if (state == MAC || state == ACC) begin
      accumulator <= accumulator + summand;
    end
  end

  // Load input on interface handshake when in ready state
  assign input_forward_ready = state == RDY;

  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin
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
        output_forward_data <= activation[accumulator[2*W-1:0]][W-1:0];
      end
    end else if (output_forward_valid & output_forward_ready) begin
        output_forward_valid <= '0;
    end
  end

  // Calculate delta on interface handshake when in delta state
  assign input_backward_ready = state == DEL;

  always @ (posedge clock) begin
    if (input_backward_valid & input_backward_ready) begin
      delta <= $signed(input_backward_data) * activation_derivative[accumulator[2*W-1:0]] >>> W;
    end
  end

  // Backward propagate errors and update weights when in the backward pass state
  // FIXME Use counter and single multiplier
  genvar j;
  generate
    for (j = 0; j < N; j = j + 1) begin
      always @(posedge clock) begin
        if (state == BWD) begin
          if (!output_backward_valid | output_backward_ready) begin
            output_backward_data[j] <= 16'((weight[j] * delta) >>> W);
            weight[j] <= weight[j] + (delta * operand[j] >>> K + W);
          end
        end
      end
    end
  endgenerate

  always @(posedge clock) begin
    if (reset) begin
      bias <= '0;
    end else if (state == BWD) begin
      if (!output_backward_valid | output_backward_ready) begin
        bias <= bias + delta >>> K;
      end
    end
  end

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
