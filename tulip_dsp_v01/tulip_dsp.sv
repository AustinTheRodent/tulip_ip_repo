module polynomial_estimator
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


/////////////////////////////////////////////////////////////////////

  assign fixed_to_float_din       = din;
  assign fixed_to_float_din_valid = din_valid;
  assign din_ready                = fixed_to_float_din_ready;

  fixed_to_float
  #(
    .G_INTEGER_BITS   (0),
    .G_FRACT_BITS     (C_ADC_DWIDTH),
    .G_SIGNED_INPUT   (true),
    .G_BUFFER_INPUT   (true),
    .G_BUFFER_OUTPUT  (true)
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
    .G_POLY_ORDER         (G_POLY_ORDER),
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

  float_to_fixed
  #(
    .G_INTEGER_BITS   (0),
    .G_FRACT_BITS     (C_ADC_DWIDTH),
    .G_SIGNED_OUTPUT  (true),
    .G_BUFFER_INPUT   (true),
    .G_BUFFER_OUTPUT  (true)
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

endmodule
