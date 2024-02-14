module polynomial_estimator_wrapper
#(
  parameter  int G_POLY_ORDER = 5,
  localparam int C_FP_DWIDTH = 32
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    enable,
  input  logic                    bypass,

  input  logic                    symmetric_mode,

  input  logic [C_FP_DWIDTH-1:0]  taps_prog_din,
  input  logic                    taps_prog_din_valid,
  output logic                    taps_prog_din_ready,
  output logic                    taps_prog_done,

  input  logic [C_FP_DWIDTH-1:0]  din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [C_FP_DWIDTH-1:0]  dout,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  logic [C_FP_DWIDTH-1:0]  core_din;
  logic                    core_din_valid;
  logic                    core_din_ready;
  logic [C_FP_DWIDTH-1:0]  core_dout;
  logic                    core_dout_valid;
  logic                    core_dout_ready;

  logic fifo_din;
  logic fifo_dout;
  logic fifo_din_valid;
  logic fifo_dout_ready;

  always_comb begin
    if (symmetric_mode == 1) begin
      core_din = {1'b0, din[C_FP_DWIDTH-2 -: C_FP_DWIDTH-1]};
    end
    else begin
      core_din = din;
    end
  end

  assign fifo_din_valid = din_valid & din_ready;
  assign fifo_dout_ready = dout_valid & dout_ready;

  assign fifo_din = din[C_FP_DWIDTH-1];

  axis_sync_fifo
  #(
    .G_ADDR_WIDTH    (2),
    .G_DATA_WIDTH    (1),
    .G_BUFFER_INPUT  (0),
    .G_BUFFER_OUTPUT (0)
  )
  u_sign_fifo
  (
    .clk             (clk),
    .reset           (reset),
    .enable          (enable),

    .din             (fifo_din),
    .din_valid       (fifo_din_valid),
    .din_ready       (),
    .din_last        (1'b0),

    .used            (),

    .dout            (fifo_dout),
    .dout_valid      (),
    .dout_ready      (fifo_dout_ready),
    .dout_last       ()
  );

  assign core_din_valid = din_valid;
  assign din_ready = core_din_ready;

  polynomial_estimator
  #(
    .G_POLY_ORDER         (G_POLY_ORDER)
  )
  u_polynomial_estimator
  (
    .clk                  (clk),
    .reset                (reset),
    .enable               (enable),
    .bypass               (bypass),

    .taps_prog_din        (taps_prog_din),
    .taps_prog_din_valid  (taps_prog_din_valid),
    .taps_prog_din_ready  (taps_prog_din_ready),
    .taps_prog_done       (taps_prog_done),

    .din                  (core_din),
    .din_valid            (core_din_valid),
    .din_ready            (core_din_ready),

    .dout                 (core_dout),
    .dout_valid           (core_dout_valid),
    .dout_ready           (core_dout_ready)
  );

  always_comb begin
    if (symmetric_mode == 1) begin
      dout = {fifo_dout, core_dout[C_FP_DWIDTH-2 -: C_FP_DWIDTH-1]};
    end
    else begin
      dout = core_dout;
    end
  end

  assign dout_valid = core_dout_valid;
  assign core_dout_ready = dout_ready;

endmodule
