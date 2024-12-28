module tulip_dsp
#(
  localparam int C_FP_DWIDTH = 32,
  localparam int C_USER_FILT_TAP_DWIDTH = 16,
  localparam int C_ADC_DWIDTH = 24
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    global_sw_resetn,

  input  logic                    lut_tf_sw_resetn,
  input  logic                    usr_fir_sw_resetn,
  input  logic                    reverb_sw_resetn,
  input  logic                    wawa_sw_resetn,
  input  logic                    vibrato_sw_resetn,
  input  logic                    chorus_sw_resetn,

  input  logic                    bypass,
  input  logic                    bypass_lut_tf, // Look Up Table Transfer Function
  input  logic                    bypass_usr_fir,
  input  logic                    bypass_reverb,
  input  logic                    bypass_wawa,
  input  logic                    bypass_vibrato,
  input  logic                    bypass_chorus,

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

  input  logic [23:0]                       prog_vibrato_gain_din, // fixed point, 2 integer bits
  input  logic                              prog_vibrato_gain_din_valid,
  output logic                              prog_vibrato_gain_din_ready,
  output logic                              prog_vibrato_gain_din_done,

  input  logic [31:0]                       prog_vibrato_chirp_depth_din,
  input  logic                              prog_vibrato_chirp_depth_din_valid,
  output logic                              prog_vibrato_chirp_depth_din_ready,
  output logic                              prog_vibrato_chirp_depth_din_done,

  input  logic [31:0]                       prog_vibrato_freq_deriv_din,
  input  logic                              prog_vibrato_freq_deriv_din_valid,
  output logic                              prog_vibrato_freq_deriv_din_ready,
  output logic                              prog_vibrato_freq_deriv_din_done,

  input  logic [63:0]                       prog_wawa_b_tap_tdata,
  input  logic                              prog_wawa_b_tap_tvalid,
  output logic                              prog_wawa_b_tap_tready,
  output logic                              prog_wawa_b_done,

  input  logic [63:0]                       prog_wawa_a_tap_tdata,
  input  logic                              prog_wawa_a_tap_tvalid,
  output logic                              prog_wawa_a_tap_tready,
  output logic                              prog_wawa_a_done,

  input  logic [7:0]                        wawa_input,

  input  logic [31:0]                       prog_vibrato_freq_offset_din,
  input  logic                              prog_vibrato_freq_offset_din_valid,
  output logic                              prog_vibrato_freq_offset_din_ready,
  output logic                              prog_vibrato_freq_offset_din_done,

  input  logic [23:0]                       prog_chorus_gain_din, // fixed point, 2 integer bits
  input  logic                              prog_chorus_gain_din_valid,
  output logic                              prog_chorus_gain_din_ready,
  output logic                              prog_chorus_gain_din_done,

  input  logic [11:0]                       prog_chorus_avg_delay_din,
  input  logic                              prog_chorus_avg_delay_din_valid,
  output logic                              prog_chorus_avg_delay_din_ready,
  output logic                              prog_chorus_avg_delay_din_done,

  input  logic [11:0]                       prog_chorus_lfo_depth_din,
  input  logic                              prog_chorus_lfo_depth_din_valid,
  output logic                              prog_chorus_lfo_depth_din_ready,
  output logic                              prog_chorus_lfo_depth_din_done,

  input  logic [31:0]                       prog_chorus_lfo_freq_din,
  input  logic                              prog_chorus_lfo_freq_din_valid,
  output logic                              prog_chorus_lfo_freq_din_ready,
  output logic                              prog_chorus_lfo_freq_din_done,

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

//  logic [C_ADC_DWIDTH-1:0]  fixed_to_float2_din;
//  logic                     fixed_to_float2_din_valid;
//  logic                     fixed_to_float2_din_ready;
//  float_t                   fixed_to_float2_dout;
//  logic                     fixed_to_float2_dout_valid;
//  logic                     fixed_to_float2_dout_ready;
//
//  float_t                   float_to_fixed2_din;
//  logic                     float_to_fixed2_din_valid;
//  logic                     float_to_fixed2_din_ready;
//  logic [C_ADC_DWIDTH-1:0]  float_to_fixed2_dout;
//  logic                     float_to_fixed2_dout_valid;
//  logic                     float_to_fixed2_dout_ready;
//
//  float_t iir_b_tap_din;
//  logic   iir_b_tap_din_valid;
//  logic   iir_b_tap_din_ready;
//  logic   iir_b_tap_din_done;
//  float_t iir_a_tap_din;
//  logic   iir_a_tap_din_valid;
//  logic   iir_a_tap_din_ready;
//  logic   iir_a_tap_din_done;
//  float_t iir_din;
//  logic   iir_din_valid;
//  logic   iir_din_ready;
//  float_t iir_dout;
//  logic   iir_dout_valid;
//  logic   iir_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  dc_blocker_din;
  logic                     dc_blocker_din_valid;
  logic                     dc_blocker_din_ready;
  float_t                   dc_blocker_dout;
  logic                     dc_blocker_dout_valid;
  logic                     dc_blocker_dout_ready;

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

  logic [63:0]              s_wawa_tdata;
  logic                     s_wawa_tvalid;
  logic                     s_wawa_tready;
  logic [63:0]              m_wawa_tdata;
  logic                     m_wawa_tvalid;
  logic                     m_wawa_tready;

  logic [C_ADC_DWIDTH-1:0]  vibrato_din;
  logic                     vibrato_din_valid;
  logic                     vibrato_din_ready;
  logic [C_ADC_DWIDTH-1:0]  vibrato_dout;
  logic                     vibrato_dout_valid;
  logic                     vibrato_dout_ready;

  logic [C_ADC_DWIDTH-1:0]  chorus_din;
  logic                     chorus_din_valid;
  logic                     chorus_din_ready;
  logic [C_ADC_DWIDTH-1:0]  chorus_dout;
  logic                     chorus_dout_valid;
  logic                     chorus_dout_ready;

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
    .enable     (global_sw_resetn),

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
  assign gain0_dout_ready   = (bypass_lut_tf == 0) ? upsample_din_ready : dc_blocker_dout_ready;

  upsample_8x_tiny_fir
  #(
    .G_DWIDTH   (C_ADC_DWIDTH)
  )
  u_upsample_8x_tiny_fir
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (global_sw_resetn),

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
    .G_ADDR_WIDTH         (10),
    .G_DWIDTH             (C_ADC_DWIDTH),
    .G_LOG2_LINEAR_STEPS  (8)
  )
  u_interpolating_lut_transfer_function
  (
    .clk                (clk),
    .reset              (reset),
    .enable             (global_sw_resetn & lut_tf_sw_resetn),
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
    .enable     (global_sw_resetn),

    .din        (downsample_din),
    .din_valid  (downsample_din_valid),
    .din_ready  (downsample_din_ready),

    .dout       (downsample_dout),
    .dout_valid (downsample_dout_valid),
    .dout_ready (downsample_dout_ready)
  );

  assign dc_blocker_din = downsample_dout;
  assign dc_blocker_din_valid = downsample_dout_valid;
  assign downsample_dout_ready = dc_blocker_din_ready;

  dc_blocker_cic
  u_dc_blocker_cic
  (
    .clk                (clk),
    .reset              (reset | (~global_sw_resetn) | (~lut_tf_sw_resetn)),
    .bypass             (bypass_lut_tf),

    .s_dc_block_tdata   (dc_blocker_din),
    .s_dc_block_tvalid  (dc_blocker_din_valid),
    .s_dc_block_tready  (dc_blocker_din_ready),

    .m_dc_block_tdata   (dc_blocker_dout),
    .m_dc_block_tvalid  (dc_blocker_dout_valid),
    .m_dc_block_tready  (dc_blocker_dout_ready)
  );

  assign user_fir_din = (bypass_lut_tf == 0) ? dc_blocker_dout : gain0_dout;
  assign user_fir_din_valid = (bypass_lut_tf == 0) ? dc_blocker_dout_valid : gain0_dout_valid;
  assign dc_blocker_dout_ready = (bypass_usr_fir == 0) ? user_fir_din_ready : user_fir_dout_ready;

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
    .enable           (global_sw_resetn & usr_fir_sw_resetn),

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
    .enable     (global_sw_resetn),

    .gain       (output_gain),

    .din        (gain1_din),
    .din_valid  (gain1_din_valid),
    .din_ready  (gain1_din_ready),

    .dout       (gain1_dout),
    .dout_valid (gain1_dout_valid),
    .dout_ready (gain1_dout_ready)
  );

  assign s_wawa_tdata[61-:C_ADC_DWIDTH] = gain1_dout;
  assign s_wawa_tvalid = gain1_dout_valid;
  assign gain1_dout_ready = s_wawa_tready;

  wawa_iir
  #(
    .G_BRAM_ADDRWIDTH     (8),
    .G_NUM_B_TAPS         (8),
    .G_NUM_A_TAPS         (8),
    .G_TAP_INTEGER_BITS   (2),
    .G_TAP_DWIDTH         (64),
    .G_DWIDTH             (64),
    .G_REFRESH_RATE       (4800)
  )
  u_wawa_iir
  (
    .clk                  (clk),
    .reset                (reset | ~global_sw_resetn | ~wawa_sw_resetn),
    .bypass               (bypass_wawa),

    .s_prog_b_tap_tdata   (prog_wawa_b_tap_tdata),
    .s_prog_b_tap_tvalid  (prog_wawa_b_tap_tvalid),
    .s_prog_b_tap_tready  (prog_wawa_b_tap_tready),
    .prog_b_done          (prog_wawa_b_done),

    .s_prog_a_tap_tdata   (prog_wawa_a_tap_tdata),
    .s_prog_a_tap_tvalid  (prog_wawa_a_tap_tvalid),
    .s_prog_a_tap_tready  (prog_wawa_a_tap_tready),
    .prog_a_done          (prog_wawa_a_done),

    .pedal_input          (wawa_input),

    .s_wawa_tdata         (s_wawa_tdata),
    .s_wawa_tvalid        (s_wawa_tvalid),
    .s_wawa_tready        (s_wawa_tready),

    .m_wawa_tdata         (m_wawa_tdata),
    .m_wawa_tvalid        (m_wawa_tvalid),
    .m_wawa_tready        (m_wawa_tready)
  );


  assign vibrato_din        = m_wawa_tdata[61-:C_ADC_DWIDTH];
  assign vibrato_din_valid  = m_wawa_tvalid;
  assign m_wawa_tready      = vibrato_din_ready;


  vibrato
  #(
    .G_NUM_VIBRATO_CHANNELS      (1)
  )
  u_vibrato
  (
    .clk                        (clk),
    .reset                      (reset),
    .enable                     (global_sw_resetn & vibrato_sw_resetn),
    .bypass                     (bypass_vibrato),

    .prog_gain_din              (prog_vibrato_gain_din              ),
    .prog_gain_din_valid        (prog_vibrato_gain_din_valid        ),
    .prog_gain_din_ready        (prog_vibrato_gain_din_ready        ),
    .prog_gain_din_done         (prog_vibrato_gain_din_done         ),

    .prog_chirp_depth_din       (prog_vibrato_chirp_depth_din       ),
    .prog_chirp_depth_din_valid (prog_vibrato_chirp_depth_din_valid ),
    .prog_chirp_depth_din_ready (prog_vibrato_chirp_depth_din_ready ),
    .prog_chirp_depth_din_done  (prog_vibrato_chirp_depth_din_done  ),

    .prog_freq_deriv_din        (prog_vibrato_freq_deriv_din        ),
    .prog_freq_deriv_din_valid  (prog_vibrato_freq_deriv_din_valid  ),
    .prog_freq_deriv_din_ready  (prog_vibrato_freq_deriv_din_ready  ),
    .prog_freq_deriv_din_done   (prog_vibrato_freq_deriv_din_done   ),

    .prog_freq_offset_din       (prog_vibrato_freq_offset_din       ),
    .prog_freq_offset_din_valid (prog_vibrato_freq_offset_din_valid ),
    .prog_freq_offset_din_ready (prog_vibrato_freq_offset_din_ready ),
    .prog_freq_offset_din_done  (prog_vibrato_freq_offset_din_done  ),

    .din                        (vibrato_din        ),
    .din_valid                  (vibrato_din_valid  ),
    .din_ready                  (vibrato_din_ready  ),

    .dout                       (vibrato_dout       ),
    .dout_valid                 (vibrato_dout_valid ),
    .dout_ready                 (vibrato_dout_ready )
  );

  assign chorus_din         = vibrato_dout;
  assign chorus_din_valid   = vibrato_dout_valid;
  assign vibrato_dout_ready = chorus_din_ready;

  chorus_effect
  #(
    .G_DWIDTH      (C_ADC_DWIDTH)
  )
  u_chorus_effect
  (
    .clk                      (clk),
    .reset                    (reset),
    .enable                   (global_sw_resetn & chorus_sw_resetn),
    .bypass                   (bypass_chorus),

    .prog_gain_din            (prog_chorus_gain_din),
    .prog_gain_din_valid      (prog_chorus_gain_din_valid),
    .prog_gain_din_ready      (prog_chorus_gain_din_ready),
    .prog_gain_din_done       (prog_chorus_gain_din_done),

    .prog_avg_delay_din       (prog_chorus_avg_delay_din),
    .prog_avg_delay_din_valid (prog_chorus_avg_delay_din_valid),
    .prog_avg_delay_din_ready (prog_chorus_avg_delay_din_ready),
    .prog_avg_delay_din_done  (prog_chorus_avg_delay_din_done),

    .prog_lfo_depth_din       (prog_chorus_lfo_depth_din),
    .prog_lfo_depth_din_valid (prog_chorus_lfo_depth_din_valid),
    .prog_lfo_depth_din_ready (prog_chorus_lfo_depth_din_ready),
    .prog_lfo_depth_din_done  (prog_chorus_lfo_depth_din_done),

    .prog_lfo_freq_din        (prog_chorus_lfo_freq_din),
    .prog_lfo_freq_din_valid  (prog_chorus_lfo_freq_din_valid),
    .prog_lfo_freq_din_ready  (prog_chorus_lfo_freq_din_ready),
    .prog_lfo_freq_din_done   (prog_chorus_lfo_freq_din_done),

    .din                      (chorus_din),
    .din_valid                (chorus_din_valid),
    .din_ready                (chorus_din_ready),

    .dout                     (chorus_dout),
    .dout_valid               (chorus_dout_valid),
    .dout_ready               (chorus_dout_ready)
  );

  assign reverb_din         = chorus_dout;
  assign reverb_din_valid   = chorus_dout_valid;
  assign chorus_dout_ready  = reverb_din_ready;

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
    .enable               (global_sw_resetn & reverb_sw_resetn),
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
