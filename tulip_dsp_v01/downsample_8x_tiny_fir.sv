module downsample_8x_tiny_fir
#(
  parameter int G_DWIDTH = 24
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

  logic [G_DWIDTH-1:0]           dec_4x_din;
  logic                          dec_4x_din_valid;
  logic                          dec_4x_din_ready;
  logic [G_DWIDTH-1:0]           dec_4x_dout;
  logic                          dec_4x_dout_valid;
  logic                          dec_4x_dout_ready;

  logic signed  [G_DWIDTH-1:0]   fir_4x_din;
  logic                          fir_4x_din_valid;
  logic                          fir_4x_din_ready;
  logic signed  [G_DWIDTH-1:0]   fir_4x_dout;
  logic                          fir_4x_dout_valid;
  logic                          fir_4x_dout_ready;

  logic [G_DWIDTH-1:0]           dec_2x_din;
  logic                          dec_2x_din_valid;
  logic                          dec_2x_din_ready;
  logic [G_DWIDTH-1:0]           dec_2x_dout;
  logic                          dec_2x_dout_valid;
  logic                          dec_2x_dout_ready;

  logic signed  [G_DWIDTH-1:0]   fir_2x_din;
  logic                          fir_2x_din_valid;
  logic                          fir_2x_din_ready;
  logic signed  [G_DWIDTH-1:0]   fir_2x_dout;
  logic                          fir_2x_dout_valid;
  logic                          fir_2x_dout_ready;

  logic unsigned [4:0]  brom_counter_2x_din;
  logic   signed [15:0] brom_counter_2x_dout;
  logic                 brom_counter_2x_din_valid;
  logic                 brom_counter_2x_dout_valid;

  logic unsigned [5:0]  brom_counter_4x_din;
  logic   signed [15:0] brom_counter_4x_dout;
  logic                 brom_counter_4x_din_valid;
  logic                 brom_counter_4x_dout_valid;

/////////////////////////////////////////////////////////////////////

  assign fir_4x_din = din;
  assign fir_4x_din_valid = din_valid;
  assign din_ready = fir_4x_din_ready;

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      brom_counter_4x_din <= 0;
      brom_counter_4x_din_valid <= 0;
    end
    else begin
      if (brom_counter_4x_din == 62) begin
        brom_counter_4x_din_valid <= 0;
      end
      else begin
        if (brom_counter_4x_din_valid == 1) begin
          brom_counter_4x_din <= brom_counter_4x_din + 1;
        end
        brom_counter_4x_din_valid <= 1;
      end
    end
  end

  fir_taps_4x_brom
  u_fir_taps_4x_brom
  (
  .clk          (clk),

  .din_address  (brom_counter_4x_din),
  .din_valid    (brom_counter_4x_din_valid),

  .dout         (brom_counter_4x_dout),
  .dout_valid   (brom_counter_4x_dout_valid)
  );

  tiny_fir
  #(
    .G_DATA_WIDTH (G_DWIDTH),
    .G_TAP_WIDTH  (16),
    .G_NUM_TAPS   (63)
  )
  u_tiny_fir_4x
  (
    .clk          (clk),
    .reset        (reset),
    .enable       (enable),

    .tap_din_valid  (brom_counter_4x_dout_valid),
    .tap_din        (brom_counter_4x_dout),

    .din          (fir_4x_din),
    .din_valid    (fir_4x_din_valid),
    .din_ready    (fir_4x_din_ready),

    .dout         (fir_4x_dout),
    .dout_valid   (fir_4x_dout_valid),
    .dout_ready   (fir_4x_dout_ready)
  );

  assign dec_4x_din = fir_4x_dout;
  assign dec_4x_din_valid = fir_4x_dout_valid;
  assign fir_4x_dout_ready = dec_4x_din_ready;

  decimate
  #(
    .G_DWIDTH        (G_DWIDTH),
    .G_DOWNSAMPLE_RATE (4)
  )
  u_decimate_4x
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (dec_4x_din),
    .din_valid  (dec_4x_din_valid),
    .din_ready  (dec_4x_din_ready),

    .dout       (dec_4x_dout),
    .dout_valid (dec_4x_dout_valid),
    .dout_ready (dec_4x_dout_ready)
  );

  assign fir_2x_din = dec_4x_dout;
  assign fir_2x_din_valid = dec_4x_dout_valid;
  assign dec_4x_dout_ready = fir_2x_din_ready;

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      brom_counter_2x_din <= 0;
      brom_counter_2x_din_valid <= 0;
    end
    else begin
      if (brom_counter_2x_din == 30) begin
        brom_counter_2x_din_valid <= 0;
      end
      else begin
        if (brom_counter_2x_din_valid == 1) begin
          brom_counter_2x_din <= brom_counter_2x_din + 1;
        end
        brom_counter_2x_din_valid <= 1;
      end
    end
  end

  fir_taps_2x_brom
  u_fir_taps_2x_brom
  (
  .clk          (clk),

  .din_address  (brom_counter_2x_din),
  .din_valid    (brom_counter_2x_din_valid),

  .dout         (brom_counter_2x_dout),
  .dout_valid   (brom_counter_2x_dout_valid)
  );

  tiny_fir
  #(
    .G_DATA_WIDTH (G_DWIDTH),
    .G_TAP_WIDTH  (16),
    .G_NUM_TAPS   (31)
  )
  u_tiny_fir_2x
  (
    .clk          (clk),
    .reset        (reset),
    .enable       (enable),

    .tap_din_valid  (brom_counter_2x_dout_valid),
    .tap_din        (brom_counter_2x_dout),

    .din          (fir_2x_din),
    .din_valid    (fir_2x_din_valid),
    .din_ready    (fir_2x_din_ready),

    .dout         (fir_2x_dout),
    .dout_valid   (fir_2x_dout_valid),
    .dout_ready   (fir_2x_dout_ready)
  );

  assign dec_2x_din = fir_2x_dout;
  assign dec_2x_din_valid = fir_2x_dout_valid;
  assign fir_2x_dout_ready = dec_2x_din_ready;

  decimate
  #(
    .G_DWIDTH        (G_DWIDTH),
    .G_DOWNSAMPLE_RATE (2)
  )
  u_decimate_2x
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (dec_2x_din),
    .din_valid  (dec_2x_din_valid),
    .din_ready  (dec_2x_din_ready),

    .dout       (dec_2x_dout),
    .dout_valid (dec_2x_dout_valid),
    .dout_ready (dec_2x_dout_ready)
  );

  assign dout = dec_2x_dout;
  assign dout_valid = dec_2x_dout_valid;
  assign dec_2x_dout_ready = dout_ready;

endmodule
