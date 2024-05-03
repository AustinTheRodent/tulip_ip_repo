module sine_taylor
#(
  parameter int G_DWIDTH = 16,
  parameter int G_TAPWIDTH = 16
)
(
  input  logic                clk,
  input  logic                reset,
  input  logic                enable,

  input  logic [G_DWIDTH-1:0] din,
  input  logic                din_valid,
  output logic                din_ready,

  output logic [G_DWIDTH-1:0] dout,
  output logic                dout_valid,
  input  logic                dout_ready
);

  localparam real C_PI = 1.57079632;
  localparam logic signed [G_DWIDTH-1:0] C_PI_INT = logic'(C_PI*real'(2**(G_TAPWIDTH-1)));



  localparam int C_TAYLOR_PARAMS = 4;

  localparam real talor_parmas_double [0:C_TAYLOR_PARAMS-1] =
  {
    1.0,
    -0.1666666666666667,
    0.008333333333333333,
    -0.0001984126984126984
  };

  logic signed [G_TAPWIDTH+1-1:0] taylor_param [0:C_TAYLOR_PARAMS-1] =
  {
    logic'(real'(2**(G_TAPWIDTH-1)) * talor_parmas_double[0]),
    logic'(real'(2**(G_TAPWIDTH-1)) * talor_parmas_double[1]),
    logic'(real'(2**(G_TAPWIDTH-1)) * talor_parmas_double[2]),
    logic'(real'(2**(G_TAPWIDTH-1)) * talor_parmas_double[3])
  };




  typedef enum
  {
    SM_INIT,
    SM_GET_INPUT,
    SM_APPLY_EXPONENT,
    SM_GET_MULT,
    SM_ACCUMULATE,
    SM_RESCALE,
    SM_SEND_OUTPUT
  } state_t;

  state_t state;

  logic signed [1+G_DWIDTH-1:0] input_store;
  logic signed [$bits(input_store)*(C_TAYLOR_PARAMS*2)-1:0] exponential_value;

  logic signed [$bits(input_store)+G_TAPWIDTH+($clog2(C_TAYLOR_PARAMS)+1)-1:0] estimate_value_n;
  logic signed [$bits(input_store)+G_TAPWIDTH+($clog2(C_TAYLOR_PARAMS)+1)-1:0] estimate_value_long;
  //logic signed [$bits(input_store)+G_TAPWIDTH+($clog2(C_TAYLOR_PARAMS)+1)-1:0] dout_long;

  logic unsigned [$clog2(C_TAYLOR_PARAMS)-1:0] alg_counter;
  logic unsigned [7:0] op_counter;
  logic unsigned [7:0] exponent_counter;

//////////////////////////////////////////

  always @ (posedge clk) begin

    logic input_store_done;

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
            //input_store         <= (signed'(din) * C_PI_INT) >> (G_DWIDTH-1);
            input_store_done    <= 0;
            op_counter          <= 1;
            exponent_counter    <= 1;
            alg_counter         <= 0;
            estimate_value_long <= 0;
            exponential_value   <= (signed'(din) * C_PI_INT);
            state               <= SM_APPLY_EXPONENT;
          end
        end

        SM_APPLY_EXPONENT : begin

          if (input_store_done == 0) begin
            input_store       <= exponential_value;
            input_store_done  <= 1;
          end

          if (op_counter == exponent_counter) begin
            op_counter        <= 0;
            exponential_value <= exponential_value >>> ((G_DWIDTH-1)*(exponent_counter));
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
          state             <= SM_ACCUMULATE;
        end

        SM_ACCUMULATE : begin
          estimate_value_long   <= estimate_value_long + estimate_value_n;
          if (alg_counter == C_TAYLOR_PARAMS-1) begin
            state               <= SM_RESCALE;
          end
          else begin
            exponential_value <= input_store;
            op_counter        <= 1;
            state             <= SM_APPLY_EXPONENT;
            alg_counter       <= alg_counter + 1;
          end
        end

        SM_RESCALE : begin
          //estimate_value_long <= estimate_value_long >>> (G_TAPWIDTH-1);
          //dout_long           <= estimate_value_long >>> (G_TAPWIDTH-1);
          dout                <= estimate_value_long >>> (G_TAPWIDTH-1);
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
