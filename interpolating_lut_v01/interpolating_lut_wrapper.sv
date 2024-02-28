module interpolating_lut_wrapper
#(
  parameter int               G_ADDR_WIDTH = 10,
  parameter int               G_DWIDTH = 24,
  parameter int               G_LOG2_LINEAR_STEPS = 8 // 2**8 steps = 256 steps
)
(
  input  logic                clk,
  input  logic                reset,
  input  logic                enable,

  input  logic                symmetric_mode,

  input  logic [G_DWIDTH-1:0] lut_prog_din,
  input  logic                lut_prog_din_valid,
  output logic                lut_prog_din_ready,
  output logic                lut_prog_din_done,

  input  logic [G_DWIDTH-1:0] din,
  input  logic                din_valid,
  output logic                din_ready,

  output logic [G_DWIDTH-1:0] dout,
  output logic                dout_valid,
  input  logic                dout_ready
);

  typedef enum
  {
    SM_INIT,
    SM_GET_INPUT,
    SM_SEND_OUTPUT
  } state_t;

  state_t state;

  localparam C_MIDPOINT_BIAS = 2**G_DWIDTH / 2;

  logic unsigned [G_DWIDTH-1:0] core_din;
  logic unsigned [G_DWIDTH-1:0] core_dout;
  logic unsigned [G_DWIDTH-1:0] core_biased_input;
  logic unsigned [G_DWIDTH-1:0] core_magnitude_input;
  logic                         din_sign_is_negative;

/////////////////////////////////////////////////////

  assign core_biased_input = unsigned'(signed'(din) + C_MIDPOINT_BIAS);
  assign core_magnitude_input = (signed'(din) >= 0) ? din : -signed'(din);

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      state <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin
          state <= SM_GET_INPUT;
        end

        SM_GET_INPUT : begin
          if (din_valid == 1 && din_ready == 1) begin
            if (signed'(din) < 0) begin
              din_sign_is_negative <= 1;
            end
            else begin
              din_sign_is_negative <= 0;
            end
            state <= SM_SEND_OUTPUT;
          end
        end

        SM_SEND_OUTPUT : begin
          if (dout_valid == 1 && dout_ready == 1) begin
            state <= SM_GET_INPUT;
          end
        end

        default : begin
        end

      endcase
    end
  end

  assign core_din = (symmetric_mode == 1) ? (core_magnitude_input <<< 1) : core_biased_input;

  interpolating_lut
  #(
    .G_ADDR_WIDTH         (G_ADDR_WIDTH),
    .G_DWIDTH             (G_DWIDTH),
    .G_LOG2_LINEAR_STEPS  (G_LOG2_LINEAR_STEPS)
  )
  u_interpolating_lut_core
  (
    .clk                  (clk),
    .reset                (reset),
    .enable               (enable),

    .lut_prog_din         (lut_prog_din),
    .lut_prog_din_valid   (lut_prog_din_valid),
    .lut_prog_din_ready   (lut_prog_din_ready),
    .lut_prog_din_done    (lut_prog_din_done),

    .din                  (core_din),
    .din_valid            (din_valid),
    .din_ready            (din_ready),

    .dout                 (core_dout),
    .dout_valid           (dout_valid),
    .dout_ready           (dout_ready)
  );

  always_comb begin
    if (symmetric_mode == 1) begin
      if (din_sign_is_negative == 1) begin
        dout <= -signed'(core_dout >> 1);
      end
      else begin
        dout <= core_dout >> 1;
      end
    end
    else begin
      dout <= signed'(core_dout) - C_MIDPOINT_BIAS;
    end
  end

endmodule
