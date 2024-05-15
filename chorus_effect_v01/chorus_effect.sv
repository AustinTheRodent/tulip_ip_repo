module chorus_effect
#(
  parameter int G_NUM_CHORUS_CHANNELS = 4,
  localparam int G_DWIDTH = 24,
  localparam int C_PROG_CHIRP_DWIDTH = 24
)
(
  input  logic                            clk,
  input  logic                            reset,
  input  logic                            enable,

  input  logic [G_DWIDTH-1:0]             prog_gain_din, // fixed point, 2 integer bits
  input  logic                            prog_gain_din_valid,
  output logic                            prog_gain_din_ready,
  output logic                            prog_gain_din_done,

  input  logic [C_PROG_CHIRP_DWIDTH-1:0]  prog_chirp_depth_din,
  input  logic                            prog_chirp_depth_din_valid,
  output logic                            prog_chirp_depth_din_ready,
  output logic                            prog_chirp_depth_din_done,

  input  logic [C_PROG_CHIRP_DWIDTH-1:0]  prog_freq_deriv_din,
  input  logic                            prog_freq_deriv_din_valid,
  output logic                            prog_freq_deriv_din_ready,
  output logic                            prog_freq_deriv_din_done,

  input  logic [C_PROG_CHIRP_DWIDTH-1:0]  prog_freq_offset_din,
  input  logic                            prog_freq_offset_din_valid,
  output logic                            prog_freq_offset_din_ready,
  output logic                            prog_freq_offset_din_done,

  input  logic [G_DWIDTH-1:0]             din,
  input  logic                            din_valid,
  output logic                            din_ready,

  output logic [G_DWIDTH-1:0]             dout,
  output logic                            dout_valid,
  input  logic                            dout_ready
);

  logic valid_ready_mod_gate;
  logic output_valid_ready_gate;

  logic [G_DWIDTH-1:0]            prog_gain         [0:G_NUM_CHORUS_CHANNELS];
  logic [C_PROG_CHIRP_DWIDTH-1:0] prog_chirp_depth  [0:G_NUM_CHORUS_CHANNELS-1];
  logic [C_PROG_CHIRP_DWIDTH-1:0] prog_freq_deriv   [0:G_NUM_CHORUS_CHANNELS-1];
  logic [C_PROG_CHIRP_DWIDTH-1:0] prog_freq_offset  [0:G_NUM_CHORUS_CHANNELS-1];

  logic                           all_prog_done;

  localparam int C_NUM_FILTER_TAPS = 255;

  typedef enum
  {
    SM_INIT,
    SM_PROGRAM,
    SM_RUN
  } state_t;
  state_t state;

  logic [7:0]   fir_rom_din_addr;
  logic         fir_rom_din_valid;
  logic [15:0]  fir_rom_dout;
  logic         fir_rom_dout_valid;

  logic [15:0]  tap_din;
  logic         tap_din_valid;
  logic         tap_din_ready;
  logic         tap_din_done;

  logic [G_DWIDTH-1:0]  mod_np_din;
  logic                 mod_np_din_valid;
  logic                 mod_np_din_ready;
  logic [G_DWIDTH-1:0]  mod_np_dout_re;
  logic [G_DWIDTH-1:0]  mod_np_dout_im;
  logic                 mod_np_dout_valid;
  logic                 mod_np_dout_ready;

  logic [G_DWIDTH-1:0]  fir_din_re;
  logic [G_DWIDTH-1:0]  fir_din_im;
  logic                 fir_din_valid;
  logic                 fir_din_ready;
  logic [G_DWIDTH-1:0]  fir_dout_re;
  logic [G_DWIDTH-1:0]  fir_dout_im;
  logic                 fir_dout_valid;
  logic                 fir_dout_ready;

  logic [G_DWIDTH-1:0]  mod_p_din_re;
  logic [G_DWIDTH-1:0]  mod_p_din_im;
  logic                 mod_p_din_valid;
  logic                 mod_p_din_ready;
  logic [G_DWIDTH-1:0]  mod_p_dout_re;
  logic [G_DWIDTH-1:0]  mod_p_dout_im;
  logic                 mod_p_dout_valid;
  logic                 mod_p_dout_ready;

  logic [G_DWIDTH-1:0]  passthrough_gain_din;
  logic                 passthrough_gain_din_valid;
  logic                 passthrough_gain_din_ready;
  logic [G_DWIDTH-1:0]  passthrough_gain_dout;
  logic                 passthrough_gain_dout_valid;
  logic                 passthrough_gain_dout_ready;

  logic [G_DWIDTH-1:0]  chorus_gain_din         [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 chorus_gain_din_valid   [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 chorus_gain_din_ready   [0:G_NUM_CHORUS_CHANNELS-1];
  logic [G_DWIDTH-1:0]  chorus_gain_dout        [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 chorus_gain_dout_valid  [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 chorus_gain_dout_ready;

  logic [G_DWIDTH-1:0]  cyclic_chirp_dout_re    [0:G_NUM_CHORUS_CHANNELS-1];
  logic [G_DWIDTH-1:0]  cyclic_chirp_dout_im    [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 cyclic_chirp_dout_valid [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 cyclic_chirp_dout_ready [0:G_NUM_CHORUS_CHANNELS-1];

  logic [G_DWIDTH-1:0]  complex_mult_din1_re;
  logic [G_DWIDTH-1:0]  complex_mult_din1_im;
  logic                 complex_mult_din1_valid;
  logic                 complex_mult_din1_ready [0:G_NUM_CHORUS_CHANNELS-1];
  logic [G_DWIDTH-1:0]  complex_mult_din2_re    [0:G_NUM_CHORUS_CHANNELS-1];
  logic [G_DWIDTH-1:0]  complex_mult_din2_im    [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 complex_mult_din2_valid [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 complex_mult_din2_ready [0:G_NUM_CHORUS_CHANNELS-1];
  logic [G_DWIDTH-1:0]  complex_mult_out_re     [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 complex_mult_out_valid  [0:G_NUM_CHORUS_CHANNELS-1];
  logic                 complex_mult_out_ready  [0:G_NUM_CHORUS_CHANNELS-1];


//////////////////////////////////////////

  always @ (posedge clk) begin

    logic [$clog2(G_NUM_CHORUS_CHANNELS)+1:0] prog_gain_counter;
    logic [$clog2(G_NUM_CHORUS_CHANNELS):0]   prog_chirp_depth_counter;
    logic [$clog2(G_NUM_CHORUS_CHANNELS):0]   prog_freq_deriv_counter;
    logic [$clog2(G_NUM_CHORUS_CHANNELS):0]   prog_freq_offset_counter;
    logic [3:0] delay_counter;

    if (reset == 1 || enable == 0) begin
      fir_rom_din_addr            <= 0;
      fir_rom_din_valid           <= 0;
      delay_counter               <= 0;

      prog_gain_din_ready         <= 0;
      prog_gain_din_done          <= 0;

      prog_chirp_depth_din_ready  <= 0;
      prog_chirp_depth_din_done   <= 0;

      prog_freq_deriv_din_ready   <= 0;
      prog_freq_deriv_din_done    <= 0;

      prog_freq_offset_din_ready  <= 0;
      prog_freq_offset_din_done   <= 0;

      all_prog_done               <= 0;

      prog_gain_counter           <= 0;
      prog_chirp_depth_counter    <= 0;
      prog_freq_deriv_counter     <= 0;
      prog_freq_offset_counter    <= 0;
      state                       <= SM_INIT;
    end
    else begin
      case (state)
        SM_INIT : begin
          if (delay_counter == 7) begin

            prog_gain_din_ready         <= 1;
            prog_chirp_depth_din_ready  <= 1;
            prog_freq_deriv_din_ready   <= 1;
            prog_freq_offset_din_ready  <= 1;

            fir_rom_din_valid           <= 1;
            state                       <= SM_PROGRAM;
          end
          else begin
            delay_counter               <= delay_counter + 1;
          end
        end

        SM_PROGRAM : begin

          if (prog_gain_din_valid & prog_gain_din_ready == 1) begin

            prog_gain[prog_gain_counter] <= prog_gain_din;

            if (prog_gain_counter == G_NUM_CHORUS_CHANNELS) begin
              prog_gain_din_ready  <= 0;
              prog_gain_din_done   <= 1;
            end
            else begin
              prog_gain_counter    <= prog_gain_counter + 1;
            end
          end

          if (prog_chirp_depth_din_valid & prog_chirp_depth_din_ready == 1) begin

            prog_chirp_depth[prog_chirp_depth_counter] <= prog_chirp_depth_din;

            if (prog_chirp_depth_counter == G_NUM_CHORUS_CHANNELS-1) begin
              prog_chirp_depth_din_ready  <= 0;
              prog_chirp_depth_din_done   <= 1;
            end
            else begin
              prog_chirp_depth_counter    <= prog_chirp_depth_counter + 1;
            end
          end

          if (prog_freq_deriv_din_valid & prog_freq_deriv_din_ready == 1) begin

            prog_freq_deriv[prog_freq_deriv_counter] <= prog_freq_deriv_din;

            if (prog_freq_deriv_counter == G_NUM_CHORUS_CHANNELS-1) begin
              prog_freq_deriv_din_ready <= 0;
              prog_freq_deriv_din_done  <= 1;
            end
            else begin
              prog_freq_deriv_counter   <= prog_freq_deriv_counter + 1;
            end
          end

          if (prog_freq_offset_din_valid & prog_freq_offset_din_ready == 1) begin

            prog_freq_offset[prog_freq_offset_counter] <= prog_freq_offset_din;

            if (prog_freq_offset_counter == G_NUM_CHORUS_CHANNELS-1) begin
              prog_freq_offset_din_ready  <= 0;
              prog_freq_offset_din_done   <= 1;
            end
            else begin
              prog_freq_offset_counter    <= prog_freq_offset_counter + 1;
            end
          end

          if (fir_rom_din_addr == C_NUM_FILTER_TAPS-1) begin
            fir_rom_din_valid <= 0;
          end
          else begin
            fir_rom_din_addr  <= fir_rom_din_addr + 1;
          end

          if
          (
            prog_gain_din_done &
            prog_chirp_depth_din_done &
            prog_freq_deriv_din_done &
            prog_freq_offset_din_done &
            tap_din_done == 1
          ) begin
            all_prog_done  <= 1;
            state          <= SM_RUN;
          end

        end

        SM_RUN : begin
        end
      endcase
    end
  end


  assign mod_np_din       = din;
  assign mod_np_din_valid = din_valid & all_prog_done;
  assign din_ready        = mod_np_din_ready & all_prog_done;

  modulate_neg_pi_div2
  #(
    .G_DWIDTH   (G_DWIDTH)
  )
  u_modulate_neg_pi_div2
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din_re     (mod_np_din),
    .din_im     (0),
    .din_valid  (mod_np_din_valid),
    .din_ready  (mod_np_din_ready),

    .dout_re    (mod_np_dout_re),
    .dout_im    (mod_np_dout_im),
    .dout_valid (mod_np_dout_valid),
    .dout_ready (mod_np_dout_ready)
  );

  half_band_brom
  u_half_band_brom
  (
    .clk          (clk),

    .din_address  (fir_rom_din_addr),
    .din_valid    (fir_rom_din_valid),

    .dout         (fir_rom_dout),
    .dout_valid   (fir_rom_dout_valid)
  );

  assign tap_din        = fir_rom_dout;
  assign tap_din_valid  = fir_rom_dout_valid;

  assign fir_din_re         = mod_np_dout_re;
  assign fir_din_im         = mod_np_dout_im;
  assign fir_din_valid      = mod_np_dout_valid;
  assign mod_np_dout_ready  = fir_din_ready;

  tiny_fir
  #(
    .G_NUM_TAPS   (C_NUM_FILTER_TAPS),
    .G_DATA_WIDTH (G_DWIDTH),
    .G_TAP_WIDTH  (16)
  )
  u_half_band_fir_re
  (
    .clk            (clk),
    .reset          (reset),
    .enable         (enable),

    .tap_din        (tap_din),
    .tap_din_valid  (tap_din_valid),
    .tap_din_ready  (tap_din_ready),
    .tap_din_done   (tap_din_done),

    .din            (fir_din_re),
    .din_valid      (fir_din_valid),
    .din_ready      (fir_din_ready),

    .dout           (fir_dout_re),
    .dout_valid     (fir_dout_valid),
    .dout_ready     (fir_dout_ready)
  );

  tiny_fir
  #(
    .G_NUM_TAPS   (C_NUM_FILTER_TAPS),
    .G_DATA_WIDTH (G_DWIDTH),
    .G_TAP_WIDTH  (16)
  )
  u_half_band_fir_im
  (
    .clk            (clk),
    .reset          (reset),
    .enable         (enable),

    .tap_din        (tap_din),
    .tap_din_valid  (tap_din_valid),
    .tap_din_ready  (),
    .tap_din_done   (),

    .din            (fir_din_im),
    .din_valid      (fir_din_valid),
    .din_ready      (),

    .dout           (fir_dout_im),
    .dout_valid     (),
    .dout_ready     (fir_dout_ready)
  );

  assign mod_p_din_re     = fir_dout_re;
  assign mod_p_din_im     = fir_dout_im;
  assign mod_p_din_valid  = fir_dout_valid;
  assign fir_dout_ready   = mod_p_din_ready;

  modulate_pi_div2
  #(
    .G_DWIDTH   (G_DWIDTH)
  )
  u_modulate_pi_div2
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din_re     (mod_p_din_re),
    .din_im     (mod_p_din_im),
    .din_valid  (mod_p_din_valid),
    .din_ready  (mod_p_din_ready),

    .dout_re    (mod_p_dout_re),
    .dout_im    (mod_p_dout_im),
    .dout_valid (mod_p_dout_valid),
    .dout_ready (mod_p_dout_ready)
  );

  always_comb begin
    valid_ready_mod_gate = 1;

    if (passthrough_gain_din_ready == 0) begin
      valid_ready_mod_gate = 0;
    end

    for (int i = 0 ; i < G_NUM_CHORUS_CHANNELS ; i++) begin
      if (complex_mult_din1_ready[i] == 0) begin
        valid_ready_mod_gate = 0;
      end
    end
  end

  assign mod_p_dout_ready = valid_ready_mod_gate;

  assign passthrough_gain_din       = mod_p_dout_re;
  assign passthrough_gain_din_valid = mod_p_dout_valid & valid_ready_mod_gate;

  gain_stage
  #(
    .G_INTEGER_BITS (2),
    .G_DECIMAL_BITS (G_DWIDTH-2),
    .G_DWIDTH       (G_DWIDTH)
  )
  u_passthrough_gain_stage
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .gain       (prog_gain[0]),

    .din        (passthrough_gain_din),
    .din_valid  (passthrough_gain_din_valid),
    .din_ready  (passthrough_gain_din_ready),

    .dout       (passthrough_gain_dout),
    .dout_valid (passthrough_gain_dout_valid),
    .dout_ready (passthrough_gain_dout_ready)
  );

  assign complex_mult_din1_re     = mod_p_dout_re;
  assign complex_mult_din1_im     = mod_p_dout_im;
  assign complex_mult_din1_valid  = mod_p_dout_valid & valid_ready_mod_gate;

  generate
    for (genvar i = 0 ; i < G_NUM_CHORUS_CHANNELS ; i++) begin

      cyclic_chirp
      #(
        .G_DIN_WIDTH  (C_PROG_CHIRP_DWIDTH),
        .G_DOUT_WIDTH (G_DWIDTH)
      )
      u_cyclic_chirp
      (
        .clk              (clk),
        .reset            (reset),
        .enable           (enable),

        .chirp_depth_din  (prog_chirp_depth[i]),
        .freq_deriv_din   (prog_freq_deriv[i]),
        .freq_offset_din  (prog_freq_offset[i]),
        .din_valid        (all_prog_done),
        .din_ready        (),

        .dout_re          (cyclic_chirp_dout_re[i]),
        .dout_im          (cyclic_chirp_dout_im[i]),
        .dout_valid       (cyclic_chirp_dout_valid[i]),
        .dout_ready       (cyclic_chirp_dout_ready[i])
      );

      assign complex_mult_din2_re[i]    = cyclic_chirp_dout_re[i];
      assign complex_mult_din2_im[i]    = cyclic_chirp_dout_im[i];
      assign complex_mult_din2_valid[i] = cyclic_chirp_dout_valid[i];
      assign cyclic_chirp_dout_ready[i] = complex_mult_din2_ready[i];

      complex_multiply
      #(
        .G_DIN1_DWIDTH    (G_DWIDTH),
        .G_DIN2_DWIDTH    (G_DWIDTH)
      )
      u_complex_multiply
      (
        .clk              (clk),
        .reset            (reset),
        .enable           (enable),

        .din1_re          (complex_mult_din1_re),
        .din1_im          (complex_mult_din1_im),
        .din1_valid       (complex_mult_din1_valid),
        .din1_ready       (complex_mult_din1_ready[i]),

        .din2_re          (complex_mult_din2_re[i]),
        .din2_im          (complex_mult_din2_im[i]),
        .din2_valid       (complex_mult_din2_valid[i]),
        .din2_ready       (complex_mult_din2_ready[i]),

        .dout_re          (complex_mult_out_re[i]),
        .dout_im          (),
        .dout_valid       (complex_mult_out_valid[i]),
        .dout_ready       (complex_mult_out_ready[i])
      );

      assign chorus_gain_din[i]         = complex_mult_out_re[i];
      assign chorus_gain_din_valid[i]   = complex_mult_out_valid[i];
      assign complex_mult_out_ready[i]  = chorus_gain_din_ready[i];

      gain_stage
      #(
        .G_INTEGER_BITS (0),
        .G_DECIMAL_BITS (G_DWIDTH),
        .G_DWIDTH       (G_DWIDTH)
      )
      u_gain_stage
      (
        .clk        (clk),
        .reset      (reset),
        .enable     (enable),

        .gain       (prog_gain[i+1]),

        .din        (chorus_gain_din[i]),
        .din_valid  (chorus_gain_din_valid[i]),
        .din_ready  (chorus_gain_din_ready[i]),

        .dout       (chorus_gain_dout[i]),
        .dout_valid (chorus_gain_dout_valid[i]),
        .dout_ready (chorus_gain_dout_ready)
      );

    end
  endgenerate;

  always_comb begin
    output_valid_ready_gate = 1;
    if (passthrough_gain_dout_valid == 0) begin
      output_valid_ready_gate = 0;
    end

    for (int i = 0 ; i < G_NUM_CHORUS_CHANNELS ; i++) begin
      if (chorus_gain_dout_valid[i] == 0) begin
        output_valid_ready_gate = 0;
      end
    end
  end

  assign dout = signed'(passthrough_gain_dout) + signed'(chorus_gain_dout[0]) + signed'(chorus_gain_dout[1]) + signed'(chorus_gain_dout[2]) + signed'(chorus_gain_dout[3]);
  assign dout_valid                   = output_valid_ready_gate;
  assign passthrough_gain_dout_ready  = dout_ready & output_valid_ready_gate;
  assign chorus_gain_dout_ready       = dout_ready & output_valid_ready_gate;

endmodule
