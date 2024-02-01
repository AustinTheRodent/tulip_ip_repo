module polynomial_estimator
#(
  parameter int G_POLY_ORDER = 5,
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

  typedef enum
  {
    SM_INIT,
    SM_GET_INPUT,
    SM_CALCULATE_STAGE_0,
    SM_POWER_STAGE_N,
    SM_GET_STAGE_OUTPUT,
    SM_ADD_STAGE_OUTPUT,
    SM_SEND_OUTPUT
  } state_t;
  state_t state;


//////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      state <= SM_INIT;
    end
    else begin
      case (state)
        SM_INIT : begin
        end
        SM_GET_INPUT : begin
        end
        SM_CALCULATE_STAGE_0 : begin
        end
        SM_POWER_STAGE_N : begin
        end

        default: begin
        end
      endcase
    end
  end

endmodule
