module sine_taylor
#(
  parameter int G_DIN_WIDTH = 16,
  parameter int G_DOUT_WIDTH = 16,
  parameter int G_TAPWIDTH = 16
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    enable,

  input  logic [G_DIN_WIDTH-1:0]  din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [G_DOUT_WIDTH-1:0] dout,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  function int return_larger(int a, int b);
    if (a >= b) begin
      return a;
    end
    else begin
      return b;
    end
  endfunction

  function int get_dwidth_expansion(int G_DIN_WIDTH, int G_DOUT_WIDTH);
    if (G_DOUT_WIDTH >= G_DIN_WIDTH) begin
      return (G_DOUT_WIDTH - G_DIN_WIDTH) + 2;
    end
    else begin
      return 0;
    end
  endfunction

  localparam int C_DWIDTH_EXPANSION = get_dwidth_expansion(G_DIN_WIDTH, G_DOUT_WIDTH);

  localparam int C_DWIDTH = G_DIN_WIDTH + C_DWIDTH_EXPANSION;
  localparam int C_TAPWIDTH = G_TAPWIDTH;

  localparam real C_PI = 1.57079632;
  //localparam logic signed [C_TAPWIDTH+1-1:0] C_PI_INT = int'(C_PI*2**(C_TAPWIDTH-1));
  localparam logic signed [C_TAPWIDTH+1-1:0] C_PI_INT = 51472;

  localparam int C_TAYLOR_PARAMS = 4;

  localparam real talor_parmas_double [0:C_TAYLOR_PARAMS-1] =
  {
    1.0,
    -0.1666666666666667,
    0.008333333333333333,
    -0.0001984126984126984
  };

  localparam logic signed [C_TAPWIDTH+1-1:0] taylor_param [0:C_TAYLOR_PARAMS-1] =
  {
    //logic'(real'(2**(C_TAPWIDTH-1)) * talor_parmas_double[0]),
    //logic'(real'(2**(C_TAPWIDTH-1)) * talor_parmas_double[1]),
    //logic'(real'(2**(C_TAPWIDTH-1)) * talor_parmas_double[2]),
    //logic'(real'(2**(C_TAPWIDTH-1)) * talor_parmas_double[3])
    32768,
    -5461,
    273,
    -7
  };

  typedef enum
  {
    SM_INIT,
    SM_GET_INPUT,
    SM_MULT_EXPONENT0,
    SM_MULT_EXPONENT1,
    SM_RIGHT_SHIFT_EXPONENT,
    SM_APPLY_EXPONENT,
    SM_GET_MULT,
    SM_ACCUMULATE,
    SM_RESCALE,
    SM_SEND_OUTPUT
  } state_t;

  state_t state;

  logic signed [1+C_DWIDTH-1:0] input_store;
  logic signed [$bits(input_store)+C_DWIDTH+5-1:0] exponential_value;
  logic signed [$bits(input_store)+C_DWIDTH+5-1:0] exponential_value_rs;

  logic signed [$bits(input_store)+C_DWIDTH+($clog2(C_TAYLOR_PARAMS)+1)-1:0] estimate_value_n;
  logic signed [$bits(input_store)+C_DWIDTH+($clog2(C_TAYLOR_PARAMS)+1)-1:0] estimate_value_long;

  logic unsigned [$clog2(C_TAYLOR_PARAMS)-1:0] alg_counter;
  logic unsigned [7:0] op_counter;
  logic unsigned [7:0] exponent_counter;

  logic signed [$bits(exponential_value)-1:0] exponential_mult_din_a;
  logic signed [C_DWIDTH+1-1:0]               exponential_mult_din_b;
  logic signed [$bits(exponential_value)-1:0] exponential_mult_dout;

//////////////////////////////////////////

  always @ (posedge clk) begin
    exponential_mult_dout <= exponential_mult_din_a*exponential_mult_din_b;
  end

  always @ (posedge clk) begin

    logic input_store_done;
    logic unsigned [7:0] exponent_rs_amount;

    if (reset == 1 || enable == 0) begin
      din_ready         <= 0;
      dout_valid        <= 0;
      op_counter        <= 1;
      exponent_counter  <= 1;
      alg_counter       <= 0;
      input_store_done  <= 0;
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
            input_store_done    <= 0;
            op_counter          <= 1;
            exponent_counter    <= 1;
            alg_counter         <= 0;
            estimate_value_long <= 0;
            exponential_mult_din_a  <= signed'(din);
            exponential_mult_din_b  <= C_PI_INT;
            exponent_rs_amount  <= (C_TAPWIDTH-C_DWIDTH_EXPANSION-1);
            state               <= SM_MULT_EXPONENT0;
          end
        end

        SM_MULT_EXPONENT0 : begin
          //exponential_value <= exponential_mult_din_a * exponential_mult_din_b;
          state             <= SM_MULT_EXPONENT1;
        end

        SM_MULT_EXPONENT1 : begin
          exponential_value <= exponential_mult_dout;
          state             <= SM_RIGHT_SHIFT_EXPONENT;
        end

        SM_RIGHT_SHIFT_EXPONENT : begin
          exponential_value <= exponential_value >>> exponent_rs_amount;
          state             <= SM_APPLY_EXPONENT;
        end

        SM_APPLY_EXPONENT : begin

          if (input_store_done == 0) begin
            input_store       <= exponential_value;
            input_store_done  <= 1;
          end

          if (op_counter == exponent_counter) begin
            op_counter        <= 0;
            exponential_value_rs <= exponential_value;
            exponent_counter  <= exponent_counter + 2;
            state             <= SM_GET_MULT;
          end
          else begin
            exponential_mult_din_a  <= exponential_value;
            exponential_mult_din_b  <= input_store;
            exponent_rs_amount  <= (C_DWIDTH-1);
            op_counter          <= op_counter + 1;
            state               <= SM_MULT_EXPONENT0;
          end

        end

        SM_GET_MULT : begin
          estimate_value_n  <= exponential_value_rs * taylor_param[alg_counter];
          state             <= SM_ACCUMULATE;
        end

        SM_ACCUMULATE : begin
          estimate_value_long   <= estimate_value_long + estimate_value_n;
          if (alg_counter == C_TAYLOR_PARAMS-1) begin
            state               <= SM_RESCALE;
          end
          else begin
            op_counter        <= exponent_counter-2;
            state             <= SM_APPLY_EXPONENT;
            alg_counter       <= alg_counter + 1;
          end
        end

        SM_RESCALE : begin
          if (C_DWIDTH_EXPANSION == 0) begin
            dout              <= estimate_value_long >>> (C_TAPWIDTH+(G_DIN_WIDTH-G_DOUT_WIDTH)-1);
          end
          else begin
            dout              <= estimate_value_long >>> (C_TAPWIDTH+(G_DIN_WIDTH-G_DOUT_WIDTH)+C_DWIDTH_EXPANSION-1);
          end

          dout_valid          <= 1;
          state               <= SM_SEND_OUTPUT;
        end

        SM_SEND_OUTPUT : begin
          if (dout_valid & dout_ready == 1) begin
            din_ready         <= 1;
            dout_valid        <= 0;
            state             <= SM_GET_INPUT;
          end
        end

        default : begin
        end

      endcase
    end
  end


endmodule
