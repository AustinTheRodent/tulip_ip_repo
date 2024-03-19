module tulip_dsp
#(
  parameter  int G_LUT_AWIDTH = 10,
  localparam int C_FP_DWIDTH = 32,
  localparam int C_USER_FILT_TAP_DWIDTH = 16,
  localparam int C_ADC_DWIDTH = 24
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    enable,

  input  logic                    bypass,
  input  logic                    bypass_lut_tf, // Look Up Table Transfer Function
  input  logic                    bypass_usr_fir,
  input  logic                    bypass_reverb,

  input  logic [31:0]             input_gain,
  input  logic [31:0]             output_gain,

  input  logic                    symmetric_mode,

  input  logic [C_ADC_DWIDTH-1:0] lut_prog_din,
  input  logic                    lut_prog_din_valid,
  output logic                    lut_prog_din_ready,
  output logic                    lut_prog_din_done,

  input  logic [C_USER_FILT_TAP_DWIDTH-1:0] usr_fir_taps_prog_din,
  input  logic                              usr_fir_taps_prog_din_valid,
  output logic                              usr_fir_taps_prog_din_ready,
  output logic                              usr_fir_taps_prog_done,

  input  logic [7:0]                        reverb_feedback_right_shift, // 8.0 unsigned fixed point
  input  logic [15:0]                       reverb_feedback_gain, // 1.15 unsigned fixed point
  input  logic [15:0]                       reverb_feedforward_gain, // 1.15 unsigned fixed point

  input  logic [C_USER_FILT_TAP_DWIDTH-1:0] reverb_taps_prog_din,
  input  logic                              reverb_taps_prog_din_valid,
  output logic                              reverb_taps_prog_din_ready,
  output logic                              reverb_taps_prog_done,

  input  logic [C_ADC_DWIDTH-1:0] din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [C_ADC_DWIDTH-1:0] dout,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  typedef logic [31:0] float_t;

  logic [C_ADC_DWIDTH-1:0]  gain0_din;
  logic                     gain0_din_valid;
  logic                     gain0_din_ready;
  logic [C_ADC_DWIDTH-1:0]  gain0_dout;
  logic                     gain0_dout_valid;
  logic                     gain0_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  lut_din;
  logic                     lut_din_valid;
  logic                     lut_din_ready;
  logic [C_ADC_DWIDTH-1:0]  lut_dout;
  logic                     lut_dout_valid;
  logic                     lut_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  gain1_din;
  logic                     gain1_din_valid;
  logic                     gain1_din_ready;
  logic [C_ADC_DWIDTH-1:0]  gain1_dout;
  logic                     gain1_dout_valid;
  logic                     gain1_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  upsample_din;
  logic                     upsample_din_valid;
  logic                     upsample_din_ready;

  logic [C_ADC_DWIDTH-1:0]  upsample_dout;
  logic                     upsample_dout_valid;
  logic                     upsample_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  fixed_to_float2_din;
  logic                     fixed_to_float2_din_valid;
  logic                     fixed_to_float2_din_ready;
  float_t                   fixed_to_float2_dout;
  logic                     fixed_to_float2_dout_valid;
  logic                     fixed_to_float2_dout_ready;

  float_t                   float_to_fixed2_din;
  logic                     float_to_fixed2_din_valid;
  logic                     float_to_fixed2_din_ready;
  logic [C_ADC_DWIDTH-1:0]  float_to_fixed2_dout;
  logic                     float_to_fixed2_dout_valid;
  logic                     float_to_fixed2_dout_ready;

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

  logic [C_ADC_DWIDTH-1:0]  user_fir_din;
  logic                     user_fir_din_valid;
  logic                     user_fir_din_ready;
  logic [C_ADC_DWIDTH-1:0]  user_fir_dout;
  logic                     user_fir_dout_valid;
  logic                     user_fir_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  reverb_din;
  logic                     reverb_din_valid;
  logic                     reverb_din_ready;
  logic [C_ADC_DWIDTH-1:0]  reverb_dout;
  logic                     reverb_dout_valid;
  logic                     reverb_dout_ready;

/////////////////////////////////////////////////////////////////////

  assign gain0_din        = din;
  assign gain0_din_valid  = din_valid;
  assign din_ready        =  (bypass == 0) ? gain0_din_ready : dout_ready;

  gain_stage
  #(
    .G_INTEGER_BITS (16),
    .G_DECIMAL_BITS (16),
    .G_DWIDTH       (C_ADC_DWIDTH)
  )
  u_input_gain_stage
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .gain       (input_gain),

    .din        (gain0_din),
    .din_valid  (gain0_din_valid),
    .din_ready  (gain0_din_ready),

    .dout       (gain0_dout),
    .dout_valid (gain0_dout_valid),
    .dout_ready (gain0_dout_ready)
  );

  assign upsample_din       = gain0_dout;
  assign upsample_din_valid = gain0_dout_valid;
  assign gain0_dout_ready   = (bypass_lut_tf == 0) ? upsample_din_ready : float_to_fixed2_dout_ready;

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

  assign lut_din = upsample_dout;
  assign lut_din_valid = upsample_dout_valid;
  assign upsample_dout_ready = lut_din_ready;

  interpolating_lut_wrapper
  #(
    .G_ADDR_WIDTH         (G_LUT_AWIDTH),
    .G_DWIDTH             (C_ADC_DWIDTH),
    .G_LOG2_LINEAR_STEPS  (8)
  )
  u_interpolating_lut_transfer_function
  (
    .clk                (clk),
    .reset              (reset),
    .enable             (enable),
    .bypass             (bypass_lut_tf),

    .symmetric_mode     (symmetric_mode),

    .lut_prog_din       (lut_prog_din),
    .lut_prog_din_valid (lut_prog_din_valid),
    .lut_prog_din_ready (lut_prog_din_ready),
    .lut_prog_din_done  (lut_prog_din_done),

    .din                (lut_din),
    .din_valid          (lut_din_valid),
    .din_ready          (lut_din_ready),

    .dout               (lut_dout),
    .dout_valid         (lut_dout_valid),
    .dout_ready         (lut_dout_ready)
  );

  assign downsample_din = lut_dout;
  assign downsample_din_valid = lut_dout_valid;
  assign lut_dout_ready = downsample_din_ready;

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

  assign fixed_to_float2_din = downsample_dout;
  assign fixed_to_float2_din_valid = downsample_dout_valid;
  assign downsample_dout_ready = fixed_to_float2_din_ready;

  fixed_to_float
  #(
    .G_INTEGER_BITS   (C_ADC_DWIDTH),
    .G_FRACT_BITS     (0),
    .G_SIGNED_INPUT   (1),
    .G_BUFFER_INPUT   (1),
    .G_BUFFER_OUTPUT  (1)
  )
  u_fixed_to_float2
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (fixed_to_float2_din),
    .din_valid        (fixed_to_float2_din_valid),
    .din_ready        (fixed_to_float2_din_ready),
    .din_last         (1'b0),

    .dout             (fixed_to_float2_dout),
    .dout_valid       (fixed_to_float2_dout_valid),
    .dout_ready       (fixed_to_float2_dout_ready),
    .dout_last        ()
  );

  assign iir_din = fixed_to_float2_dout;
  assign iir_din_valid = fixed_to_float2_dout_valid;
  assign fixed_to_float2_dout_ready = iir_din_ready;

  always @ (posedge clk) begin

    logic unsigned [7:0] b_taps_prog_counter;
    logic unsigned [7:0] a_taps_prog_counter;

    float_t iir_b_tap_din_array [0:2] =
    {
      32'h3F7F6E94,
      32'hBFFF6E94,
      32'h3F7F6E94
    };

    float_t iir_a_tap_din_array [0:2] =
    {
      32'h3F800000,
      32'hBFFF6E6A,
      32'h3F7EDD7A
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

  assign float_to_fixed2_din = iir_dout;
  assign float_to_fixed2_din_valid = iir_dout_valid;
  assign iir_dout_ready = float_to_fixed2_din_ready;

  float_to_fixed
  #(
    .G_INTEGER_BITS   (C_ADC_DWIDTH),
    .G_FRACT_BITS     (0),
    .G_SIGNED_OUTPUT  (1),
    .G_BUFFER_INPUT   (1),
    .G_BUFFER_OUTPUT  (1)
  )
  u_float_to_fixed2
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (float_to_fixed2_din),
    .din_valid        (float_to_fixed2_din_valid),
    .din_ready        (float_to_fixed2_din_ready),
    .din_last         (1'b0),

    .dout             (float_to_fixed2_dout),
    .dout_valid       (float_to_fixed2_dout_valid),
    .dout_ready       (float_to_fixed2_dout_ready),
    .dout_last        ()
  );

  assign user_fir_din = (bypass_lut_tf == 0) ? float_to_fixed2_dout : gain0_dout;
  assign user_fir_din_valid = (bypass_lut_tf == 0) ? float_to_fixed2_dout_valid : gain0_dout_valid;
  assign float_to_fixed2_dout_ready = (bypass_usr_fir == 0) ? user_fir_din_ready : user_fir_dout_ready;

  tiny_fir
  #(
    .G_NUM_TAPS   (129),
    .G_DATA_WIDTH (C_ADC_DWIDTH),
    .G_TAP_WIDTH  (C_USER_FILT_TAP_DWIDTH)
  )
  u_user_fir
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .tap_din          (usr_fir_taps_prog_din),
    .tap_din_valid    (usr_fir_taps_prog_din_valid),
    .tap_din_ready    (usr_fir_taps_prog_din_ready),
    .tap_din_done     (usr_fir_taps_prog_done),

    .din              (user_fir_din),
    .din_valid        (user_fir_din_valid),
    .din_ready        (user_fir_din_ready),

    .dout             (user_fir_dout),
    .dout_valid       (user_fir_dout_valid),
    .dout_ready       (user_fir_dout_ready)
  );

  assign gain1_din            = (bypass_usr_fir == 0) ? user_fir_dout : user_fir_din;
  assign gain1_din_valid      = (bypass_usr_fir == 0) ? user_fir_dout_valid : user_fir_din_valid;
  assign user_fir_dout_ready  = gain1_din_ready;

  gain_stage
  #(
    .G_INTEGER_BITS (16),
    .G_DECIMAL_BITS (16),
    .G_DWIDTH       (C_ADC_DWIDTH)
  )
  u_output_gain_stage
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .gain       (output_gain),

    .din        (gain1_din),
    .din_valid  (gain1_din_valid),
    .din_ready  (gain1_din_ready),

    .dout       (gain1_dout),
    .dout_valid (gain1_dout_valid),
    .dout_ready (gain1_dout_ready)
  );

  assign reverb_din       = gain1_dout;
  assign reverb_din_valid = gain1_dout_valid;
  assign gain1_dout_ready = reverb_din_ready;

  reverb_wrapper
  #(
    .G_NUM_STAGES_LOG2  (6),
    .G_STAGE_DEPTH_LOG2 (10),
    .G_DATA_WIDTH       (C_ADC_DWIDTH),
    .G_TAP_WIDTH        (16)
  )
  u_reverb
  (
    .clk                  (clk),
    .reset                (reset),
    .enable               (enable),
    .bypass               (bypass_reverb),

    .feedback_right_shift (reverb_feedback_right_shift),
    .feedback_gain        (reverb_feedback_gain),
    .feedforward_gain     (reverb_feedforward_gain),

    .tap_din              (reverb_taps_prog_din),
    .tap_din_valid        (reverb_taps_prog_din_valid),
    .tap_din_ready        (reverb_taps_prog_din_ready),
    .tap_din_done         (reverb_taps_prog_done),

    .din                  (reverb_din),
    .din_valid            (reverb_din_valid),
    .din_ready            (reverb_din_ready),

    .dout                 (reverb_dout),
    .dout_valid           (reverb_dout_valid),
    .dout_ready           (reverb_dout_ready)
  );

  assign dout               = (bypass == 0) ? reverb_dout : din;
  assign dout_valid         = (bypass == 0) ? reverb_dout_valid : din_valid;
  assign reverb_dout_ready  = dout_ready;


endmodule
