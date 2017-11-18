module node #(
  parameter N = 2,
  parameter K = 2
)(
  input logic clock,
  input logic reset,
  input logic train,

  input  logic operand_valid,
  input  logic [N-1:0][7:0] operand_data,
  output logic operand_ready,

  output logic product_valid,
  output logic [15:0] product_data,
  input  logic product_ready,

  input  logic delta_valid,
  input  logic [15:0] delta_data,
  output logic delta_ready,

  output logic feedback_valid,
  output logic [N-1:0][15:0] feedback_data,
  input  logic feedback_ready
);
  localparam W = 8;
  typedef logic signed [W:0] std_t;
  typedef logic signed [2*$bits(std_t)-1:0] ext_t;

  typedef logic [$clog2(N)-1:0] cnt_t;
  localparam CNT = cnt_t'(N - 1);
  cnt_t counter;

  std_t operand [N];
  ext_t weight [N];
  ext_t bias = '0;
  ext_t summand = '0;
  ext_t accumulator = '0;
  ext_t delta = '0;

  logic [15:0] error [N];

  enum logic [3:0] { RDY, MUL, MAC, ACC, PRD, DEL, ERR, FBK, UPD } state;

  // Initialize weights to small pseudorandom values and operands to zero
  initial begin
    for (int i = 0; i < N; i = i + 1) begin
      weight[i] = ext_t'($random % 16);
      operand[i] = '0;
    end
  end

  // Load operands
  assign operand_ready = state == RDY;

  genvar n;
  generate
    for (n = 0; n < N; n = n + 1) begin
      always @(posedge clock) begin
        if (operand_valid & operand_ready) begin
          operand[n] <= std_t'(operand_data[n]);
        end
      end
    end
  endgenerate

  // Cycle counter
  always @(posedge clock) begin
    if (reset) begin
      counter <= '0;
    end else if (state == MUL || state == MAC || state == ERR || state == UPD) begin
      if (counter == CNT) begin
        counter <= '0;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  // Multiply and accumulate
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

  // Output cross product
  always @(posedge clock) begin
    if (reset) begin
      product_valid <= '0;
    end else if (state == PRD) begin
      if (!product_valid) begin
        product_valid <= '1;
        product_data <= accumulator[15:0];
      end else if (product_ready) begin
        product_valid <= '0;
      end
    end
  end

  // Load delta
  assign delta_ready = state == DEL;

  always @ (posedge clock) begin
    if (delta_valid & delta_ready)
      delta <= ext_t'($signed(delta_data));
  end

  // Compute error terms
  always @ (posedge clock) begin
    if (state == ERR)
      error[counter] <= 16'(weight[counter] * delta >>> W);
  end

  // Backward propagate errors
  always @ (posedge clock) begin
    if (reset) begin
      feedback_valid <= '0;
    end else if (state == FBK) begin
      if (!feedback_valid) begin
        feedback_valid <= '1;
      end else if (feedback_ready) begin
        feedback_valid <= '0;
      end
    end
  end

  genvar k;
  generate
    for (k = 0; k < N; k = k + 1) begin
      always @ (posedge clock) begin
        if (state == FBK && feedback_valid != '1)
            feedback_data[k] <= error[k];
      end
    end
  endgenerate

  // Update weights
  // TODO reset
  always @ (posedge clock) begin
    if (state == UPD) begin
      weight[counter] <= weight[counter] + (delta * operand[counter] >>> K + W);
    end
  end

  // State machine logic
  always @(posedge clock) begin
    if (reset) begin
      state <= RDY;
    end else begin
      case (state)
        RDY:
          if (operand_valid)
            state <= MUL;
        MUL:
          state <= MAC;
        MAC:
          if (counter == CNT)
            state <= ACC;
        ACC:
          state <= PRD;
        PRD:
          if (product_valid & product_ready)
            state <= (train) ? DEL : RDY;
        DEL:
          if (delta_valid & delta_ready)
            state <= ERR;
        ERR:
          if (counter == CNT)
            state <= FBK;
        FBK:
          if (feedback_valid & feedback_ready)
            state <= UPD;
        UPD:
          if (counter == CNT)
            state <= RDY;
        default:
          $fatal(0, "invalid state: %h", state);
      endcase
    end
  end

endmodule
