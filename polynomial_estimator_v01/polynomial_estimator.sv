module polynomial_estimator
#(
  parameter  int G_POLY_ORDER = 5,
  localparam int C_FP_DWIDTH = 32
)
(
  input  logic                   clk,
  input  logic                   reset,
  input  logic                   enable,

  input  logic [C_FP_DWIDTH-1:0] taps_prog_din,
  input  logic                   taps_prog_din_valid,
  output logic                   taps_prog_din_ready,
  output logic                   taps_prog_done,

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
    SM_PROG_TAPS,
    SM_GET_INPUT,
    SM_START_STAGE_N,
    SM_GET_STAGE_N,
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
  float_t float_mult_dout_store;
  logic float_mult_dout_valid;

  float_t float_add_din1;
  float_t float_add_din2;
  logic float_add_din_valid;
  float_t float_add_dout;
  logic float_add_dout_valid;

  float_t taps [0:G_POLY_ORDER-1];

  logic unsigned [7:0] stage_counter;
  logic unsigned [7:0] mult_counter;
  logic unsigned [7:0] taps_prog_counter;

//////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      din_ready            <= 0;
      dout_valid           <= 0;
      float_mult_din_valid <= 0;
      float_add_din_valid  <= 0;
      taps_prog_din_ready  <= 0;
      taps_prog_done       <= 0;
      state <= SM_INIT;
    end
    else begin
      case (state)
        SM_INIT : begin
          taps_prog_din_ready <= 1;
          taps_prog_counter   <= 0;
          state               <= SM_PROG_TAPS;
        end

        SM_PROG_TAPS : begin
          if (taps_prog_din_valid == 1 && taps_prog_din_ready == 1) begin

            taps[taps_prog_counter] <= taps_prog_din;

            if (taps_prog_counter == G_POLY_ORDER-1) begin
              taps_prog_din_ready   <= 0;
              taps_prog_done        <= 1;
              din_ready             <= 1;
              state                 <= SM_GET_INPUT;
            end
            else begin
              taps_prog_counter     <= taps_prog_counter + 1;
            end
          end
        end

        SM_GET_INPUT : begin
          if (din_valid == 1 && din_ready == 1) begin
            din_ready      <= 0;
            input_store    <= din;
            accumulate_reg <= taps[0];
            stage_counter  <= 1;
            mult_counter   <= 0;
            state          <= SM_START_STAGE_N;
          end
        end

        SM_START_STAGE_N : begin
          float_mult_din1      <= input_store;
          float_mult_din2      <= taps[stage_counter];
          float_mult_din_valid <= 1;
          state                <= SM_GET_STAGE_N;
        end

        SM_GET_STAGE_N : begin
          if (float_mult_dout_valid == 1) begin
            if (mult_counter == stage_counter-1) begin
              float_mult_dout_store  <= float_mult_dout;
              state                  <= SM_ADD_STAGE_OUTPUT;
              mult_counter           <= 0;
              float_mult_din_valid   <= 0;
            end
            else begin
              float_mult_din1        <= float_mult_dout;
              float_mult_din2        <= input_store;
              mult_counter           <= mult_counter + 1;
              float_mult_din_valid   <= 1;
            end
          end
          else begin
            float_mult_din_valid     <= 0;
          end
        end

        SM_ADD_STAGE_OUTPUT : begin
          float_add_din1      <= accumulate_reg;
          float_add_din2      <= float_mult_dout_store;

          if (float_add_dout_valid == 1) begin
            accumulate_reg      <= float_add_dout;
            float_add_din_valid <= 0;
            if (stage_counter == G_POLY_ORDER-1) begin
              stage_counter <= 0;
              dout          <= float_add_dout;
              dout_valid    <= 1;
              state         <= SM_SEND_OUTPUT;
            end
            else begin
              stage_counter <= stage_counter + 1;
              state         <= SM_START_STAGE_N;
            end
          end
          else begin
            float_add_din_valid <= 1;
          end
        end

        SM_SEND_OUTPUT : begin
          if (dout_valid == 1 && dout_ready == 1) begin
            dout_valid <= 0;
            din_ready  <= 1;
            state      <= SM_GET_INPUT;
          end
        end

        default : begin
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

  floating_point_add_valid_only
  u_floating_point_add_valid_only
    (
      .clk             (clk),

      .din1            (float_add_din1),
      .din2            (float_add_din2),
      .din_valid       (float_add_din_valid),

      .dout            (float_add_dout),
      .dout_valid      (float_add_dout_valid)
    );

endmodule
