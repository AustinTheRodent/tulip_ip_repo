module decimate
#(
  parameter int G_DWIDTH = 24,
  parameter int G_DOWNSAMPLE_RATE = 4
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

  typedef enum
  {
    SM_INIT,
    SM_PASS_DATA,
    SM_SKIP_DATA
  } state_t;
  state_t state;

  logic unsigned [15:0] decimate_counter;

/////////////////////////////////////////////////////////////////////

  always_comb begin
    case (state)
      SM_PASS_DATA : begin
        din_ready   = dout_ready;
        dout        = din;
        dout_valid  = din_valid;
      end

      SM_SKIP_DATA : begin
        din_ready   = 1;
        dout        = 0;
        dout_valid  = 0;
      end

      default : begin
        din_ready   = 0;
        dout        = 0;
        dout_valid  = 0;
      end
    endcase
  end

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      state <= SM_INIT;
    end
    else begin
      case (state)
        SM_INIT : begin
          state <= SM_PASS_DATA;
        end

        SM_PASS_DATA : begin
          if (din_valid == 1 && din_ready == 1) begin
            if (G_DOWNSAMPLE_RATE > 1) begin
              decimate_counter  <= 1;
              state           <= SM_SKIP_DATA;
            end
          end
        end

        SM_SKIP_DATA : begin
          if (din_valid == 1 && din_ready == 1) begin
            if (decimate_counter == G_DOWNSAMPLE_RATE-1) begin
              state <= SM_PASS_DATA;
            end
            else begin
              decimate_counter <= decimate_counter + 1;
            end
          end
        end

        default : begin
        end
      endcase
    end
  end

endmodule
