module sine_taylor
#(
  parameter int G_DWIDTH = 16,
  parameter int G_TAPWIDTH = 16
)
(
  input  logic                clk,
  input  logic                reset,
  input  logic                enable,
  input  logic                bypass,

  input  logic [G_DWIDTH-1:0] din,
  input  logic                din_valid,
  output logic                din_ready,

  output logic [G_DWIDTH-1:0] dout,
  output logic                dout_valid,
  input  logic                dout_ready
);

  localparam C_TAYLOR_PARAMS = 5;

  static real talor_parmas_double [0:C_TAYLOR_PARAMS-1] =
  {
    1.570796326794897,
    -0.2617993877991494,
    0.01308996938995747,
    -0.0003116659378561302,
    4.328693581335143e-06
  };

  function real max_mag (ref real input_array [], int array_len);

    real max_val = 0;
    real tmp = 0;

    for (int i = 0 ; i < array_len ; i++) begin
      if (input_array[i] < 0) begin
        tmp = -input_array[i];
      end
      else begin
        tmp = input_array[i];
      end

      if (tmp > max_val) begin
        max_val = tmp;
      end

    end

    return max_val;

  endfunction

  static logic [G_TAPWIDTH+$clog2(max_mag(talor_parmas_double))-1:0] taylor_param [0:C_TAYLOR_PARAMS-1];

  generate
    for (genvar i = 0 ; i < C_TAYLOR_PARAMS ; i++) begin
      assign taylor_param[i] = logic'(2**(G_TAPWIDTH-2) * talor_parmas_double[i]);
    end
  endgenerate



  typedef enum
  {
    SM_INIT,
    SM_GET_INPUT,
    SM_APPLY_EXPONENT,
    SM_GET_MULT,
    SM_ACCUMULATE,
    SM_SEND_OUTPUT
  } state_t;

  state_t state;

  logic signed [G_DWIDTH-1:0] input_store;
  logic signed [G_DWIDTH*(C_TAYLOR_PARAMS*2-1)-1:0] exponential_value;

  logic signed [G_DWIDTH+G_TAPWIDTH+$clog2(C_TAYLOR_PARAMS)-1] estimate_value_n;
  logic signed [G_DWIDTH+G_TAPWIDTH+$clog2(C_TAYLOR_PARAMS)-1] estimate_value_long;

  logic unsigned [$clog2(C_TAYLOR_PARAMS)-1:0] alg_counter;
  logic unsigned [7:0] op_counter;
  logic unsigned [7:0] exponent_counter;

//////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      din_ready         <= 0;
      dout_valid        <= 0;
      op_counter        <= 1;
      exponent_counter  <= 1;
      alg_counter       <= 0;
      state       <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin
          estimate_value_long <= 0;
          din_ready           <= 1;
          state               <= SM_GET_INPUT;
        end

        SM_GET_INPUT : begin
          if (din_valid & din_ready == 1) begin
            din_ready           <= 0;
            input_store         <= din;
            op_counter          <= 1;
            exponent_counter    <= 1;
            alg_counter         <= 0;
            estimate_value_long <= 0;
            exponential_value   <= din;
            state               <= SM_APPLY_EXPONENT;
          end
        end

        SM_APPLY_EXPONENT : begin
          if (op_counter == exponent_counter) begin
            op_counter        <= 0;
            exponential_value <= exponential_value >>> ((G_DWIDTH-1)*(exponent_counter-1));
            exponent_counter  <= exponent_counter + 2;
            state             <= SM_GET_MULT;
          end
          else begin
            exponential_value <= exponential_value * input_store;
            op_counter        <= op_counter + 1;
          end

        end

        SM_GET_MULT : begin
          estimate_value_n  <= exponential_value * taylor_param[alg_counter];
          state             <= SM_ADD_STAGE_OUTPUT;
        end

        SM_ADD_STAGE_OUTPUT : begin
          estimate_value_long <= estimate_value_long + estimate_value_n;
          if (alg_counter == C_TAYLOR_PARAMS-1) begin
            estimate_value_n  <= estimate_value_n >>> (G_TAP_WIDTH); // >>> (G_TAP_WIDTH+1) ?
            dout_valid        <= 1;
            state             <= SM_SEND_OUTPUT;
          end
          else begin
            state             <= SM_GET_MULT;
            alg_counter       <= alg_counter + 1;
          end
        end

        SM_SEND_OUTPUT : begin
          if (dout_valid & dout_ready == 1) begin
            din_ready   <= 1;
            dout_valid  <= 0;
            state       <= SM_GET_INPUT;
          end
        end

        default : begin
        end

      endcase
    end
  end


endmodule
