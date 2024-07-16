module dds_taylor
#(
  parameter int G_DIN_WIDTH = 24,
  parameter int G_DOUT_WIDTH = 16,
  parameter int G_COMPLEX_OUTPUT = 0
)
(
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    enable,

  input  logic [G_DIN_WIDTH-1:0]  din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [G_DOUT_WIDTH-1:0] dout_re,
  output logic [G_DOUT_WIDTH-1:0] dout_im,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  logic signed [G_DIN_WIDTH-1:0] phi_re;
  logic signed [G_DIN_WIDTH-1:0] phi2_re;
  logic signed [G_DIN_WIDTH-2:0] phi3_re;
  logic signed [G_DIN_WIDTH-1:0] phi_im;
  logic signed [G_DIN_WIDTH-1:0] phi2_im;
  logic signed [G_DIN_WIDTH-2:0] phi3_im;

//////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      phi_re <= (1 <<< (G_DIN_WIDTH-2));
      phi_im <= 0;
    end
    else begin
      if (din_valid & din_ready == 1) begin
        phi_re <= phi_re + signed'(din);
        phi_im <= phi_im + signed'(din);
      end
    end
  end

  always_comb begin
    if (phi_re == (1 <<< (G_DIN_WIDTH-2))) begin
      phi2_re = signed'(1 <<< (G_DIN_WIDTH-2)) - 1;
    end
    else if (phi_re > (1 <<< (G_DIN_WIDTH-2))) begin
      phi2_re = signed'(1 <<< (G_DIN_WIDTH-1)) - phi_re;
    end
    else if (phi_re < -(1 <<< (G_DIN_WIDTH-2))) begin
      phi2_re = -signed'(1 <<< (G_DIN_WIDTH-1)) - phi_re;
    end
    else begin
      phi2_re = phi_re;
    end
  end

  always_comb begin
    if (phi_im == (1 <<< (G_DIN_WIDTH-2))) begin
      phi2_im = signed'(1 <<< (G_DIN_WIDTH-2)) - 1;
    end
    else if (phi_im > (1 <<< (G_DIN_WIDTH-2))) begin
      phi2_im = signed'(1 <<< (G_DIN_WIDTH-1)) - phi_im;
    end
    else if (phi_im < -(1 <<< (G_DIN_WIDTH-2))) begin
      phi2_im = -signed'(1 <<< (G_DIN_WIDTH-1)) - phi_im;
    end
    else begin
      phi2_im = phi_im;
    end
  end

  assign phi3_re = phi2_re;
  assign phi3_im = phi2_im;

  sine_taylor
  #(
    .G_DIN_WIDTH  (G_DIN_WIDTH-1),
    .G_DOUT_WIDTH (G_DOUT_WIDTH)
  )
  u_sine_taylor_re
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (phi3_re),
    .din_valid  (din_valid),
    .din_ready  (din_ready),

    .dout       (dout_re),
    .dout_valid (dout_valid),
    .dout_ready (dout_ready)
  );

  generate
    if (G_COMPLEX_OUTPUT == 1) begin
      sine_taylor
      #(
        .G_DIN_WIDTH  (G_DIN_WIDTH-1),
        .G_DOUT_WIDTH (G_DOUT_WIDTH)
      )
      u_sine_taylor_im
      (
        .clk        (clk),
        .reset      (reset),
        .enable     (enable),

        .din        (phi3_im),
        .din_valid  (din_valid),
        .din_ready  (),

        .dout       (dout_im),
        .dout_valid (),
        .dout_ready (dout_ready)
      );
    end
    else begin
      assign dout_im = 0;
    end
  endgenerate

endmodule
