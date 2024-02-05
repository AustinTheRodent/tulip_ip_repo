module tulip_dsp
#(
  parameter  int G_POLY_ORDER = 5,
  localparam int C_FP_DWIDTH = 32,
  localparam int C_ADC_DWIDTH = 24
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    enable,

  input  logic [C_FP_DWIDTH-1:0]  polynomial_taps_prog_din,
  input  logic                    polynomial_taps_prog_din_valid,
  output logic                    polynomial_taps_prog_din_ready,
  output logic                    polynomial_taps_prog_done,

  input  logic [C_ADC_DWIDTH-1:0] din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [C_ADC_DWIDTH-1:0] dout,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  typedef logic [31:0] float_t;

  logic [C_ADC_DWIDTH-1:0]  upsample_din;
  logic                     upsample_din_valid;
  logic                     upsample_din_ready;

  logic [C_ADC_DWIDTH-1:0]  upsample_dout;
  logic                     upsample_dout_valid;
  logic                     upsample_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  fixed_to_float_din;
  logic                     fixed_to_float_din_valid;
  logic                     fixed_to_float_din_ready;
  float_t                   fixed_to_float_dout;
  logic                     fixed_to_float_dout_valid;
  logic                     fixed_to_float_dout_ready;

  float_t poly_est_din;
  logic   poly_est_din_valid;
  logic   poly_est_din_ready;
  float_t poly_est_dout;
  logic   poly_est_dout_valid;
  logic   poly_est_dout_ready;

  float_t                   float_to_fixed_din;
  logic                     float_to_fixed_din_valid;
  logic                     float_to_fixed_din_ready;
  logic [C_ADC_DWIDTH-1:0]  float_to_fixed_dout;
  logic                     float_to_fixed_dout_valid;
  logic                     float_to_fixed_dout_ready;

  float_t iir_b_tap_din;
  logic   iir_b_tap_din_valid;
  logic   iir_b_tap_din_ready;
  logic   iir_b_tap_din_done;
  float_t iir_a_tap_din;
  logic   iir_a_tap_din_valid;
  logic   iir_a_tap_din_ready;
  logic   iir_a_tap_din_done;
  float_t iir_din;
  logic   iir_din_valid;
  logic   iir_din_ready;
  float_t iir_dout;
  logic   iir_dout_valid;
  logic   iir_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  downsample_din;
  logic                     downsample_din_valid;
  logic                     downsample_din_ready;

  logic [C_ADC_DWIDTH-1:0]  downsample_dout;
  logic                     downsample_dout_valid;
  logic                     downsample_dout_ready;

/////////////////////////////////////////////////////////////////////

  assign upsample_din       = din;
  assign upsample_din_valid = din_valid;
  assign din_ready          = upsample_din_ready;

  upsample_8x_tiny_fir
  #(
    .G_DWIDTH   (C_ADC_DWIDTH)
  )
  u_upsample_8x_tiny_fir
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (upsample_din),
    .din_valid  (upsample_din_valid),
    .din_ready  (upsample_din_ready),

    .dout       (upsample_dout),
    .dout_valid (upsample_dout_valid),
    .dout_ready (upsample_dout_ready)
  );

  assign fixed_to_float_din       = upsample_dout;
  assign fixed_to_float_din_valid = upsample_dout_valid;
  assign upsample_dout_ready      = fixed_to_float_din_ready;

  fixed_to_float
  #(
    .G_INTEGER_BITS   (0),
    .G_FRACT_BITS     (C_ADC_DWIDTH),
    .G_SIGNED_INPUT   (1),
    .G_BUFFER_INPUT   (1),
    .G_BUFFER_OUTPUT  (1)
  )
  u_fixed_to_float
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (fixed_to_float_din),
    .din_valid        (fixed_to_float_din_valid),
    .din_ready        (fixed_to_float_din_ready),
    .din_last         (1'b0),

    .dout             (fixed_to_float_dout),
    .dout_valid       (fixed_to_float_dout_valid),
    .dout_ready       (fixed_to_float_dout_ready),
    .dout_last        ()
  );

  assign poly_est_din               = fixed_to_float_dout;
  assign poly_est_din_valid         = fixed_to_float_dout_valid;
  assign fixed_to_float_dout_ready  = poly_est_din_ready;

  polynomial_estimator
  #(
    .G_POLY_ORDER         (G_POLY_ORDER)
  )
  u_polynomial_estimator
  (
    .clk                  (clk),
    .reset                (reset),
    .enable               (enable),

    .taps_prog_din        (polynomial_taps_prog_din),
    .taps_prog_din_valid  (polynomial_taps_prog_din_valid),
    .taps_prog_din_ready  (polynomial_taps_prog_din_ready),
    .taps_prog_done       (polynomial_taps_prog_done),

    .din                  (poly_est_din),
    .din_valid            (poly_est_din_valid),
    .din_ready            (poly_est_din_ready),

    .dout                 (poly_est_dout),
    .dout_valid           (poly_est_dout_valid),
    .dout_ready           (poly_est_dout_ready)
  );

  assign iir_din              = poly_est_dout;
  assign iir_din_valid        = poly_est_dout_valid;
  assign poly_est_dout_ready  = iir_din_ready;

  always @ (posedge clk) begin

    logic unsigned [7:0] b_taps_prog_counter;
    logic unsigned [7:0] a_taps_prog_counter;

    float_t iir_b_tap_din_array [0:2] =
    {
      32'h3F7E4CB3,
      32'hBFFE4CB3,
      32'h3F7E4CB3
    };

    float_t iir_a_tap_din_array [0:2] =
    {
      32'h3F800000,
      32'hBFFE4B41,
      32'h3F7C9C4A
    };

    if (reset == 1 || enable == 0) begin
      iir_b_tap_din       <= iir_b_tap_din_array[0];
      iir_a_tap_din       <= iir_a_tap_din_array[0];
      b_taps_prog_counter <= 0;
      a_taps_prog_counter <= 0;
      iir_b_tap_din_valid <= 0;
      iir_a_tap_din_valid <= 0;
    end
    else begin
      iir_b_tap_din_valid <= 1;
      iir_a_tap_din_valid <= 1;

      if (iir_b_tap_din_valid == 1 && iir_b_tap_din_ready == 1) begin
        if (b_taps_prog_counter < 2) begin
          iir_b_tap_din       <= iir_b_tap_din_array[b_taps_prog_counter+1];
          b_taps_prog_counter <= b_taps_prog_counter + 1;
        end
      end

      if (iir_a_tap_din_valid == 1 && iir_a_tap_din_ready == 1) begin
        if (a_taps_prog_counter < 2) begin
          iir_a_tap_din       <= iir_a_tap_din_array[a_taps_prog_counter+1];
          a_taps_prog_counter <= a_taps_prog_counter + 1;
        end
      end

    end
  end


  tiny_iir_floating_point
  #(
    .G_DEGREE(3)
  )
  u_tiny_iir_floating_point_dc_blocker
  (
    .clk            (clk),
    .reset          (reset),
    .enable         (enable),
    .bypass         (1'b0),

    .b_tap          (iir_b_tap_din),
    .b_tap_valid    (iir_b_tap_din_valid),
    .b_tap_ready    (iir_b_tap_din_ready),
    .b_tap_done     (iir_b_tap_din_done),

    .a_tap          (iir_a_tap_din),
    .a_tap_valid    (iir_a_tap_din_valid),
    .a_tap_ready    (iir_a_tap_din_ready),
    .a_tap_done     (iir_a_tap_din_done),

    .din            (iir_din),
    .din_valid      (iir_din_valid),
    .din_ready      (iir_din_ready),

    .dout           (iir_dout),
    .dout_valid     (iir_dout_valid),
    .dout_ready     (iir_dout_ready)
  );

  assign float_to_fixed_din       = iir_dout;
  assign float_to_fixed_din_valid = iir_dout_valid;
  assign iir_dout_ready           = float_to_fixed_din_ready;

  float_to_fixed
  #(
    .G_INTEGER_BITS   (0),
    .G_FRACT_BITS     (C_ADC_DWIDTH),
    .G_SIGNED_OUTPUT  (1),
    .G_BUFFER_INPUT   (1),
    .G_BUFFER_OUTPUT  (1)
  )
  u_float_to_fixed
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (float_to_fixed_din),
    .din_valid        (float_to_fixed_din_valid),
    .din_ready        (float_to_fixed_din_ready),
    .din_last         (1'b0),

    .dout             (float_to_fixed_dout),
    .dout_valid       (float_to_fixed_dout_valid),
    .dout_ready       (float_to_fixed_dout_ready),
    .dout_last        ()
  );

  assign downsample_din             = float_to_fixed_dout;
  assign downsample_din_valid       = float_to_fixed_dout_valid;
  assign float_to_fixed_dout_ready  = downsample_din_ready;


  downsample_8x_tiny_fir
  #(
    .G_DWIDTH     (C_ADC_DWIDTH)
  )
  u_downsample_8x_tiny_fir
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (downsample_din),
    .din_valid  (downsample_din_valid),
    .din_ready  (downsample_din_ready),

    .dout       (downsample_dout),
    .dout_valid (downsample_dout_valid),
    .dout_ready (downsample_dout_ready)
  );

  assign dout                   = downsample_dout;
  assign dout_valid             = downsample_dout_valid;
  assign downsample_dout_ready  = dout_ready;

endmodule
