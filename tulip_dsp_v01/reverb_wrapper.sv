module reverb_wrapper
#(
  parameter int G_NUM_STAGES_LOG2 = 2,
  parameter int G_STAGE_DEPTH_LOG2 = 2,
  parameter int G_DATA_WIDTH = 16,
  parameter int G_TAP_WIDTH = 16
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    enable,
  input  logic                    bypass,

  input  logic [7:0]              feedback_right_shift,
  input  logic [15:0]             feedback_gain, // 1.15 unsigned fixed point

  input  logic [G_TAP_WIDTH-1:0]  tap_din,
  input  logic                    tap_din_valid,
  output logic                    tap_din_ready,
  output logic                    tap_din_done,

  input  logic [G_DATA_WIDTH-1:0] din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [G_DATA_WIDTH-1:0] dout,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  logic first_samp_done;

  logic signed [G_DATA_WIDTH-1:0] in_buff_din;
  logic                           in_buff_din_valid;
  logic                           in_buff_din_ready;
  logic signed [G_DATA_WIDTH-1:0] in_buff_dout;
  logic                           in_buff_dout_valid;
  logic                           in_buff_dout_ready;

  localparam int C_FIR_DWIDTH = 16;

  logic signed [C_FIR_DWIDTH-1:0] out_buff_din;
  logic                           out_buff_din_valid;
  logic                           out_buff_din_ready;
  logic signed [C_FIR_DWIDTH-1:0] out_buff_dout;
  logic signed [G_DATA_WIDTH-1:0] out_buff_dout_long;
  logic signed [G_DATA_WIDTH-1:0] out_buff_dout_ls;
  logic                           out_buff_dout_valid;
  logic                           out_buff_dout_ready;

  logic signed [C_FIR_DWIDTH-1:0]      fb_buff_din;
  logic signed [G_NUM_STAGES_LOG2+G_STAGE_DEPTH_LOG2+C_FIR_DWIDTH+G_TAP_WIDTH+16+1-1:0] fb_buff_din_long;
  logic signed [C_FIR_DWIDTH+G_TAP_WIDTH+16+1-1:0] fb_buff_din_rs;
  logic                                fb_buff_din_valid;
  logic                                fb_buff_din_ready;
  logic signed [C_FIR_DWIDTH-1:0]      fb_buff_dout;
  logic                                fb_buff_dout_valid;
  logic                                fb_buff_dout_ready;

  logic signed [C_FIR_DWIDTH-1:0] fir_din;
  logic                           fir_din_valid;
  logic                           fir_din_ready;
  //logic signed [C_FIR_DWIDTH-1:0] fir_dout;
  logic signed [G_NUM_STAGES_LOG2+G_STAGE_DEPTH_LOG2+C_FIR_DWIDTH+G_TAP_WIDTH-1:0] fir_dout;
  logic signed [G_NUM_STAGES_LOG2+G_STAGE_DEPTH_LOG2+C_FIR_DWIDTH+G_TAP_WIDTH-1:0] fir_dout_rs;
  logic signed [C_FIR_DWIDTH-1:0] fir_dout_short;
  logic                           fir_dout_valid;
  logic                           fir_dout_ready;

  logic signed [G_DATA_WIDTH-1:0] din_rs;
  logic signed [C_FIR_DWIDTH-1:0] din_rs_short;

////////////////////////////////////////////////////////////

  assign din_rs = din >>> (G_DATA_WIDTH-C_FIR_DWIDTH);
  assign din_rs_short = din_rs;
  assign fir_din = (first_samp_done == 0) ? din_rs_short : din_rs_short + fb_buff_dout;

  assign din_ready = (first_samp_done == 0) ? in_buff_din_ready & fir_din_ready : in_buff_din_ready & fir_din_ready & fb_buff_dout_valid;

  assign in_buff_din_valid = fir_din_valid & fir_din_ready;
  assign in_buff_din = din;

  axis_buffer
  #(
    .G_DWIDTH         (G_DATA_WIDTH)
  )
  u_input_in_buff
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (in_buff_din),
    .din_valid        (in_buff_din_valid),
    .din_ready        (in_buff_din_ready),
    .din_last         (0),

    .dout             (in_buff_dout),
    .dout_valid       (in_buff_dout_valid),
    .dout_ready       (in_buff_dout_ready),
    .dout_last        ()
  );

  assign in_buff_dout_ready = dout_valid & dout_ready;

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      first_samp_done <= 0;
    end
    else begin
      if (din_valid == 1 && din_ready == 1) begin
        first_samp_done <= 1;
      end
    end
  end

  assign fir_din_valid = (first_samp_done == 0) ? din_valid & in_buff_din_ready : din_valid & in_buff_din_ready & fb_buff_dout_valid;

  configurable_fir
  #(
    .G_NUM_STAGES_LOG2  (G_NUM_STAGES_LOG2),
    .G_STAGE_DEPTH_LOG2 (G_STAGE_DEPTH_LOG2),
    .G_DATA_WIDTH       (C_FIR_DWIDTH),
    .G_TAP_WIDTH        (G_TAP_WIDTH),
    .G_OUTPUT_UNSCALED  (1)
  )
  u_fir_core
  (
    .clk                (clk),
    .reset              (reset),
    .enable             (enable),
    .bypass             (1'b0),

    .tap_din            (tap_din),
    .tap_din_valid      (tap_din_valid),
    .tap_din_ready      (tap_din_ready),
    .tap_din_done       (tap_din_done),

    .din                (fir_din),
    .din_valid          (fir_din_valid),
    .din_ready          (fir_din_ready),

    .dout               (fir_dout),
    .dout_valid         (fir_dout_valid),
    .dout_ready         (fir_dout_ready)
  );

  assign out_buff_din_valid = fir_dout_valid & fb_buff_din_ready;
  assign fb_buff_din_valid = fir_dout_valid & out_buff_din_ready;
  assign fir_dout_ready = out_buff_din_ready & fb_buff_din_ready;

  //todo: clip output (no rollover)
  assign fir_dout_rs = fir_dout >>> feedback_right_shift;
  assign fir_dout_short = fir_dout_rs;
  assign fb_buff_din_long = fir_dout_short * signed'({1'b0 , feedback_gain});
  assign fb_buff_din_rs = fb_buff_din_long >>> 15;
  assign fb_buff_din = fb_buff_din_rs;

  axis_buffer
  #(
    .G_DWIDTH         (C_FIR_DWIDTH)
  )
  u_feedback_buff
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (fb_buff_din),
    .din_valid        (fb_buff_din_valid),
    .din_ready        (fb_buff_din_ready),
    .din_last         (0),

    .dout             (fb_buff_dout),
    .dout_valid       (fb_buff_dout_valid),
    .dout_ready       (fb_buff_dout_ready),
    .dout_last        ()
  );

  assign fb_buff_dout_ready = fir_din_valid & fir_din_ready;

  assign out_buff_din = fir_dout;

  axis_buffer
  #(
    .G_DWIDTH         (C_FIR_DWIDTH)
  )
  u_output_buff
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (out_buff_din),
    .din_valid        (out_buff_din_valid),
    .din_ready        (out_buff_din_ready),
    .din_last         (0),

    .dout             (out_buff_dout),
    .dout_valid       (out_buff_dout_valid),
    .dout_ready       (out_buff_dout_ready),
    .dout_last        ()
  );

  assign out_buff_dout_long = out_buff_dout;
  assign out_buff_dout_ls = out_buff_dout_long <<< (G_DATA_WIDTH-C_FIR_DWIDTH);
  assign dout = out_buff_dout_ls + in_buff_dout;

  assign out_buff_dout_ready = dout_valid & dout_ready;

  assign dout_valid = in_buff_dout_valid & out_buff_dout_valid;

endmodule
