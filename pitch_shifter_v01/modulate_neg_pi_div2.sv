module modulate_neg_pi_div2
#(
  parameter int G_DWIDTH = 24
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable,

  input  logic [G_DWIDTH-1:0] din_re,
  input  logic [G_DWIDTH-1:0] din_im,
  input  logic                din_valid,
  output logic                din_ready,

  output logic [G_DWIDTH-1:0] dout_re,
  output logic [G_DWIDTH-1:0] dout_im,
  output logic                dout_valid,
  input  logic                dout_ready
);

  typedef enum
  {
    SM_INIT,
    SM_GET_INPUT,
    SM_SEND_OUTPUT
  } state_t;
  state_t state;

  logic unsigned [1:0] counter;

  logic [G_DWIDTH-1:0] din_re_store;
  logic [G_DWIDTH-1:0] din_im_store;

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      din_ready   <= 0;
      dout_valid  <= 0;
      counter     <= 0;
      state       <= SM_INIT;
    end
    else begin
      case (state)
        SM_INIT : begin
          din_ready <= 1;
          state     <= SM_GET_INPUT;
        end

        SM_GET_INPUT : begin
          if (din_valid & din_ready == 1) begin
            din_re_store  <= din_re;
            din_im_store  <= din_im;
            din_ready     <= 0;
            dout_valid    <= 1;
            state         <= SM_SEND_OUTPUT;
          end
        end

        SM_SEND_OUTPUT : begin
          if (dout_valid & dout_ready == 1) begin
            din_ready     <= 1;
            dout_valid    <= 0;
            counter       <= counter + 1;
            state         <= SM_GET_INPUT;
          end
        end
      endcase
    end
  end

//  always @ (posedge clk) begin
//    if (reset == 1 || enable == 0) begin
//      counter <= 0;
//    end
//    else begin
//      if (din_valid & din_ready == 1) begin
//        counter <= counter + 1;
//      end
//    end
//  end

  always_comb begin
    case (counter)
      0 : begin
        dout_re = din_re_store;
        dout_im = din_im_store;
      end

      1 : begin
        dout_re = din_im_store;
        dout_im = -signed'(din_re_store);
      end

      2 : begin
        dout_re = -signed'(din_re_store);
        dout_im = -signed'(din_im_store);
      end

      default : begin
        dout_re = -signed'(din_im_store);
        dout_im = din_re_store;
      end
    endcase
  end

  //assign dout_valid = din_valid;
  //assign din_ready  = dout_ready;

endmodule
