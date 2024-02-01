module polynomial_estimator
#(
  parameter  int G_POLY_ORDER = 5,
  localparam int C_FP_DWIDTH = 32
)
(
  input  logic                   clk,
  input  logic                   reset,
  input  logic                   enable,

  input  logic [C_FP_DWIDTH-1:0] din,
  input  logic                   din_valid,
  output logic                   din_ready,

  output logic [C_FP_DWIDTH-1:0] dout,
  output logic                   dout_valid,
  input  logic                   dout_ready

);

  typedef enum
  {
    SM_INIT,
    SM_GET_INPUT,
    SM_CALCULATE_STAGE_0,
    SM_POWER_STAGE_N,
    SM_GET_STAGE_OUTPUT,
    SM_ADD_STAGE_OUTPUT,
    SM_SEND_OUTPUT
  } state_t;
  state_t state;

  typedef logic [31:0] float_t;
  float_t accumulate_reg;

  float_t input_store;
  float_t float_mult_din1;
  float_t float_mult_din2;
  logic float_mult_din_valid;
  float_t float_mult_dout;
  logic float_mult_dout_valid;

  float_t taps [0:G_POLY_ORDER-1];

  logic unsigned [7:0] stage_counter;

//////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      state <= SM_INIT;
    end
    else begin
      case (state)
        SM_INIT : begin
          //accumulate_reg <= 0;
          state          <= SM_GET_INPUT;
        end
        SM_GET_INPUT : begin
          if (din_valid == 1 && din_ready == 1) begin
            input_store <= din;
            state       <= SM_CALCULATE_STAGE_0;
          end
        end

        SM_CALCULATE_STAGE_0 : begin
          accumulate_reg <= taps[0];
          stage_counter  <= 1;
          state 
        end

        SM_POWER_STAGE_N : begin
        end

        default: begin
        end
      endcase
    end
  end

  floating_point_mult_valid_only
  u_floating_point_mult_valid_only
    (
      .clk             (clk),

      .din1            (float_mult_din1),
      .din2            (float_mult_din2),
      .din_valid       (float_mult_din_valid),

      .dout            (float_mult_dout),
      .dout_valid      (float_mult_dout_valid)
    );
  
entity floating_point_add_valid_only is
  port
  (
    clk             : in  std_logic;
    reset           : in  std_logic;
    enable          : in  std_logic;

    din1            : in  std_logic_vector(31 downto 0);
    din2            : in  std_logic_vector(31 downto 0);
    din_valid       : in  std_logic;

    dout            : out std_logic_vector(31 downto 0);
    dout_valid      : out std_logic
  );
  
endmodule
