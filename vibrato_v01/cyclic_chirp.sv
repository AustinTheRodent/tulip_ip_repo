module cyclic_chirp
#(
  parameter int G_DIN_WIDTH = 24,
  parameter int G_DOUT_WIDTH = 24
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    enable,

  input  logic [G_DIN_WIDTH-1:0]  chirp_depth_din,
  input  logic [G_DIN_WIDTH-1:0]  freq_deriv_din,
  input  logic [G_DIN_WIDTH-1:0]  freq_offset_din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [G_DOUT_WIDTH-1:0] dout_re,
  output logic [G_DOUT_WIDTH-1:0] dout_im,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  typedef enum
  {
    SM_INIT,
    SM_RUN
  } state_t;

  state_t state;

  logic unsigned [G_DIN_WIDTH-1:0]  chirp_depth_store;
  logic signed [G_DIN_WIDTH-1:0]    freq_deriv_store;
  logic signed [G_DIN_WIDTH-1:0]    freq_offset_store;
  logic signed [G_DIN_WIDTH-1:0]    phase_offset_re_store;
  logic signed [G_DIN_WIDTH-1:0]    phase_offset_im_store;


  logic core_din_valid;

  logic signed [G_DIN_WIDTH-1:0]      dds0_dout;
  logic signed [1+G_DIN_WIDTH-1:0]    dds0_dout_l;
  logic dds0_dout_valid;
  logic dds0_dout_ready;

  logic signed [1+G_DIN_WIDTH-1:0]    gain_stage_dout_l;
  logic signed [G_DIN_WIDTH-1:0]      gain_stage_dout;
  logic                               gain_stage_dout_valid;
  logic                               gain_stage_dout_ready;

  logic signed [G_DOUT_WIDTH-1:0]     dds_chirp_dout_re;
  logic signed [G_DOUT_WIDTH-1:0]     dds_chirp_dout_im;
  logic                               dds_chirp_dout_valid;
  logic                               dds_chirp_dout_ready;

//////////////////////////////////////////


  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      core_din_valid  <= 0;
      din_ready       <= 0;
      state           <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin
          if (din_valid & din_ready == 1) begin

            chirp_depth_store     <= unsigned'(chirp_depth_din);
            freq_deriv_store      <= signed'(freq_deriv_din);
            freq_offset_store     <= signed'(freq_offset_din);

            din_ready             <= 0;
            core_din_valid        <= 1;
            state                 <= SM_RUN;
          end
          else begin
            din_ready             <= 1;
          end
        end

        default : begin
        end

      endcase
    end
  end

  dds_taylor
  #(
    .G_DIN_WIDTH      (G_DIN_WIDTH),
    .G_DOUT_WIDTH     (G_DIN_WIDTH),
    .G_COMPLEX_OUTPUT (0)
  )
  u_dds_taylor_freq_deriv
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (freq_deriv_store),
    .din_valid        (core_din_valid),
    .din_ready        (),

    .dout_re          (dds0_dout),
    .dout_im          (),
    .dout_valid       (dds0_dout_valid),
    .dout_ready       (dds0_dout_ready)
  );

  //assign dds0_scaled = dds0_dout * signed'({0,chirp_depth_store});
  //assign dds0_scaled_rs = dds0_scaled >>> G_DIN_WIDTH;
  //assign dds0_scaled_short = dds0_scaled_rs;

  assign dds0_dout_l = dds0_dout;


  gain_stage
  #(
    .G_INTEGER_BITS (0),
    .G_DECIMAL_BITS (G_DIN_WIDTH),
    .G_DWIDTH       (G_DIN_WIDTH)
  )
  u_gain_stage
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .gain       ({0,chirp_depth_store}),

    .din        (dds0_dout),
    .din_valid  (dds0_dout_valid),
    .din_ready  (dds0_dout_ready),

    .dout       (gain_stage_dout),
    .dout_valid (gain_stage_dout_valid),
    .dout_ready (gain_stage_dout_ready)
  );

  //assign gain_stage_dout = gain_stage_dout_l;

  dds_taylor
  #(
    .G_DIN_WIDTH      (G_DIN_WIDTH),
    .G_DOUT_WIDTH     (G_DOUT_WIDTH),
    .G_COMPLEX_OUTPUT (1)
  )
  u_dds_taylor_chirp_out
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (gain_stage_dout + freq_offset_store),
    .din_valid        (gain_stage_dout_valid),
    .din_ready        (gain_stage_dout_ready),

    .dout_re          (dout_re),
    .dout_im          (dout_im),
    .dout_valid       (dout_valid),
    .dout_ready       (dout_ready)
  );


endmodule
