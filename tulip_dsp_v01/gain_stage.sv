module gain_stage
#(
  parameter int G_INTEGER_BITS = 16,
  parameter int G_DECIMAL_BITS = 16,
  parameter int G_DWIDTH = 24
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable,

  input  logic [G_INTEGER_BITS+G_DECIMAL_BITS-1:0] gain,

  input  logic [G_DWIDTH-1:0] din,
  input  logic                din_valid,
  output logic                din_ready,

  output logic [G_DWIDTH-1:0] dout,
  output logic                dout_valid,
  input  logic                dout_ready
);

  logic signed [G_DWIDTH-1:0] din_buff_dout;
  logic                       din_buff_dout_valid;
  logic                       din_buff_dout_ready;

  logic signed [G_DWIDTH+G_INTEGER_BITS+G_DECIMAL_BITS-1:0] mult_long;
  logic [G_DWIDTH+G_INTEGER_BITS+G_DECIMAL_BITS-1:0] mult_rs;

  logic signed [G_DWIDTH+G_INTEGER_BITS+G_DECIMAL_BITS-1:0] dout_buff_din;
  logic                                                     dout_buff_din_valid;
  logic                                                     dout_buff_din_ready;
  logic signed [G_DWIDTH+G_INTEGER_BITS+G_DECIMAL_BITS-1:0] dout_buff_dout;
  logic                                                     dout_buff_dout_valid;
  logic                                                     dout_buff_dout_ready;

  axis_buffer
  #(
    .G_DWIDTH (G_DWIDTH)
  )
  u_input_axis_buffer
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (din),
    .din_valid  (din_valid),
    .din_ready  (din_ready),
    .din_last   (1'b0),

    .dout       (din_buff_dout),
    .dout_valid (din_buff_dout_valid),
    .dout_ready (din_buff_dout_ready),
    .dout_last  ()
  );

  assign mult_long = din_buff_dout*signed'({1'b0,gain});
  assign mult_rs = mult_long >>> G_DECIMAL_BITS;

  assign dout_buff_din = mult_rs;
  assign dout_buff_din_valid = din_buff_dout_valid;
  assign din_buff_dout_ready = dout_buff_din_ready;

  axis_buffer
  #(
    .G_DWIDTH ($bits(dout_buff_din))
  )
  u_output_axis_buffer
  (
    .clk        (clk),
    .reset      (reset),
    .enable     (enable),

    .din        (dout_buff_din),
    .din_valid  (dout_buff_din_valid),
    .din_ready  (dout_buff_din_ready),
    .din_last   (1'b0),

    .dout       (dout_buff_dout),
    .dout_valid (dout_buff_dout_valid),
    .dout_ready (dout_buff_dout_ready),
    .dout_last  ()
  );

  always_comb begin
    if (dout_buff_dout > 2**(G_DWIDTH-1)-1) begin
      dout = 2**(G_DWIDTH-1)-1;
    end
    else if (dout_buff_dout < -(2**(G_DWIDTH-1))) begin
      dout = -(2**(G_DWIDTH-1));
    end
    else begin
      dout = dout_buff_dout[G_DWIDTH-1 -: G_DWIDTH];
    end
  end

  assign dout_valid = dout_buff_dout_valid;
  assign dout_buff_dout_ready = dout_ready;

endmodule

