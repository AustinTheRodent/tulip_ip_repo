module upsample_8x_tiny_fir
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

  logic [G_DWIDTH-1:0]           zi_4x_dout;
  logic                          zi_4x_dout_valid;
  logic                          zi_4x_dout_ready;

  logic signed  [G_DWIDTH-1:0]   fir_4x_dout;
  logic                          fir_4x_dout_valid;
  logic                          fir_4x_dout_ready;

  logic signed  [G_DWIDTH+2-1:0] fir_4x_dout_long;
  logic signed  [G_DWIDTH+2-1:0] fir_4x_dout_ls;
  logic signed  [G_DWIDTH-1:0]   fir_4x_dout_clip;


  logic [G_DWIDTH-1:0]           zi_2x_dout;
  logic                          zi_2x_dout_valid;
  logic                          zi_2x_dout_ready;

  logic signed  [G_DWIDTH-1:0]   fir_2x_dout;
  logic                          fir_2x_dout_valid;
  logic                          fir_2x_dout_ready;

  logic signed  [G_DWIDTH+2-1:0] fir_2x_dout_long;
  logic signed  [G_DWIDTH+2-1:0] fir_2x_dout_ls;
  logic signed  [G_DWIDTH-1:0]   fir_2x_dout_clip;

  logic unsigned [4:0]  brom_counter_2x_din;
  logic   signed [15:0] brom_counter_2x_dout;
  logic                 brom_counter_2x_din_valid;
  logic                 brom_counter_2x_dout_valid;

  logic unsigned [5:0]  brom_counter_4x_din;
  logic   signed [15:0] brom_counter_4x_dout;
  logic                 brom_counter_4x_din_valid;
  logic                 brom_counter_4x_dout_valid;

/////////////////////////////////////////////////////////////////////

  zero_insert
  #(
    .G_DWIDTH        (G_DWIDTH),
    .G_UPSAMPLE_RATE (4)
  )
  u_zero_insert_4x
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (din),
    .din_valid  (din_valid),
    .din_ready  (din_ready),

    .dout       (zi_4x_dout),
    .dout_valid (zi_4x_dout_valid),
    .dout_ready (zi_4x_dout_ready)
  );

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
    .G_DWIDTH     (G_DWIDTH),
    .G_TAP_RES    (16),
    .G_NUM_TAPS   (63)
  )
  u_tiny_fir_4x
  (
    .clk          (clk),
    .reset        (reset),
    .enable       (enable),
    .bypass       (1'b0),

    .tap_wr       (brom_counter_4x_dout_valid),
    .tap_val      (brom_counter_4x_dout),
    .tap_wr_done  (),

    .din          (zi_4x_dout),
    .din_valid    (zi_4x_dout_valid),
    .din_ready    (zi_4x_dout_ready),
    .din_last     (1'b0),

    .dout         (fir_4x_dout),
    .dout_valid   (fir_4x_dout_valid),
    .dout_ready   (fir_4x_dout_ready),
    .dout_last    ()
  );

  always_comb begin
    fir_4x_dout_long = fir_4x_dout;
    fir_4x_dout_ls = fir_4x_dout_long <<< 2;
    if (fir_4x_dout_ls > 2**(G_DWIDTH-1)-1) begin
      fir_4x_dout_clip = 2**(G_DWIDTH-1)-1;
    end
    else if (fir_4x_dout_ls < -2**(G_DWIDTH-1)) begin
      fir_4x_dout_clip = -2**(G_DWIDTH-1);
    end
    else begin
      fir_4x_dout_clip = fir_4x_dout_ls;
    end
  end

  zero_insert
  #(
    .G_DWIDTH        (G_DWIDTH),
    .G_UPSAMPLE_RATE (2)
  )
  u_zero_insert_2x
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (fir_4x_dout_clip),
    .din_valid  (fir_4x_dout_valid),
    .din_ready  (fir_4x_dout_ready),

    .dout       (zi_2x_dout),
    .dout_valid (zi_2x_dout_valid),
    .dout_ready (zi_2x_dout_ready)
  );

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
    .G_DWIDTH     (G_DWIDTH),
    .G_TAP_RES    (16),
    .G_NUM_TAPS   (31)
  )
  u_tiny_fir_2x
  (
    .clk          (clk),
    .reset        (reset),
    .enable       (enable),
    .bypass       (1'b0),

    .tap_wr       (brom_counter_2x_dout_valid),
    .tap_val      (brom_counter_2x_dout),
    .tap_wr_done  (),

    .din          (zi_2x_dout),
    .din_valid    (zi_2x_dout_valid),
    .din_ready    (zi_2x_dout_ready),
    .din_last     (1'b0),

    .dout         (fir_2x_dout),
    .dout_valid   (fir_2x_dout_valid),
    .dout_ready   (fir_2x_dout_ready),
    .dout_last    ()
  );

  always_comb begin
    fir_2x_dout_long = fir_2x_dout;
    fir_2x_dout_ls = fir_2x_dout_long <<< 1;
    if (fir_2x_dout_ls > 2**(G_DWIDTH-1)-1) begin
      fir_2x_dout_clip = 2**(G_DWIDTH-1)-1;
    end
    else if (fir_2x_dout_ls < -2**(G_DWIDTH-1)) begin
      fir_2x_dout_clip = -2**(G_DWIDTH-1);
    end
    else begin
      fir_2x_dout_clip = fir_2x_dout_ls;
    end
  end

  assign dout = fir_2x_dout_clip;
  assign dout_valid = fir_2x_dout_valid;
  assign fir_2x_dout_ready = dout_ready;

endmodule
