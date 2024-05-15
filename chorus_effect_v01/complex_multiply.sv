module complex_multiply
#(
  parameter int G_DIN1_DWIDTH = 16,
  parameter int G_DIN2_DWIDTH = 16
)
(
  input  logic  clk,
  input  logic  reset,
  input  logic  enable,

  input  logic [G_DIN1_DWIDTH-1:0]  din1_re,
  input  logic [G_DIN1_DWIDTH-1:0]  din1_im,
  input  logic                      din1_valid,
  output logic                      din1_ready,

  input  logic [G_DIN2_DWIDTH-1:0]  din2_re,
  input  logic [G_DIN2_DWIDTH-1:0]  din2_im,
  input  logic                      din2_valid,
  output logic                      din2_ready,

  output logic [1+G_DIN1_DWIDTH+G_DIN2_DWIDTH-1:0]  dout_re,
  output logic [1+G_DIN1_DWIDTH+G_DIN2_DWIDTH-1:0]  dout_im,
  output logic                                      dout_valid,
  input  logic                                      dout_ready
);

  typedef enum
  {
    SM_INIT,
    SM_GET_INPUT,
    SM_MULTIPLY,
    SM_ADD,
    SM_SEND_OUTPUT
  } state_t;

  state_t state;

  logic signed [G_DIN1_DWIDTH-1:0] din1_store_re;
  logic signed [G_DIN1_DWIDTH-1:0] din1_store_im;

  logic signed [G_DIN1_DWIDTH-1:0] din2_store_re;
  logic signed [G_DIN1_DWIDTH-1:0] din2_store_im;

  logic signed [1+G_DIN1_DWIDTH+G_DIN2_DWIDTH-1:0] mult_i1i2;
  logic signed [1+G_DIN1_DWIDTH+G_DIN2_DWIDTH-1:0] mult_q1q2;
  logic signed [1+G_DIN1_DWIDTH+G_DIN2_DWIDTH-1:0] mult_i1q2;
  logic signed [1+G_DIN1_DWIDTH+G_DIN2_DWIDTH-1:0] mult_q1i2;

///////////////////////////////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      din1_ready  <= 1;
      din2_ready  <= 1;
      dout_valid  <= 0;
      state       <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin
          din1_ready  <= 1;
          din2_ready  <= 1;
          state       <= SM_GET_INPUT;
        end

        SM_GET_INPUT : begin

          if (din1_valid & din1_ready == 1) begin
            din1_store_re <= signed'(din1_re);
            din1_store_im <= signed'(din1_im);
            din1_ready    <= 0;
          end

          if (din2_valid & din2_ready == 1) begin
            din2_store_re <= signed'(din2_re);
            din2_store_im <= signed'(din2_im);
            din2_ready    <= 0;
          end

          if (din1_ready == 0 && din2_ready == 0) begin
            state         <= SM_MULTIPLY;
          end

        end

        SM_MULTIPLY : begin

          mult_i1i2 <= din1_store_re * din2_store_re;
          mult_q1q2 <= din1_store_im * din2_store_im;
          mult_i1q2 <= din1_store_re * din2_store_im;
          mult_q1i2 <= din1_store_im * din2_store_re;

          state     <= SM_ADD;

        end

        SM_ADD : begin

          dout_re     <= mult_i1i2 - mult_q1q2;
          dout_im     <= mult_i1q2 + mult_q1i2;

          dout_valid  <= 1;
          state       <= SM_SEND_OUTPUT;

        end

        SM_SEND_OUTPUT : begin
          if (dout_valid & dout_ready == 1) begin
            din1_ready  <= 1;
            din2_ready  <= 1;
            dout_valid  <= 0;
            state       <= SM_GET_INPUT;
          end
        end

      endcase
    end
  end

endmodule
