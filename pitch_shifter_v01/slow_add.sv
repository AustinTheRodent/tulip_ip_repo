module slow_add
#(
  parameter int G_DWIDTH = 16,
  parameter int G_BUS_WIDTH = 4
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable,

  input  logic [G_DWIDTH-1:0] din [0:G_BUS_WIDTH-1],
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
    SM_ADD,
    SM_CLIP,
    SM_SEND_OUTPUT
  } state_t;
  state_t state;

  logic signed [G_DWIDTH-1:0] din_store [0:G_BUS_WIDTH-1];
  logic signed [G_DWIDTH+$clog2(G_BUS_WIDTH)-1:0] added_reg;
  logic unsigned [$clog2(G_BUS_WIDTH):0]          add_counter;

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      din_ready   <= 0;
      dout_valid  <= 0;
      added_reg   <= 0;
      add_counter <= 0;
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
            for (int i = 0 ; i < G_BUS_WIDTH ; i++) begin
              din_store[i]  <= signed'(din[i]);
            end
            add_counter     <= 0;
            added_reg       <= 0;
            din_ready       <= 0;
            state           <= SM_ADD;
          end
        end

        SM_ADD : begin
          if (add_counter == G_BUS_WIDTH-1) begin
            state       <= SM_CLIP;
          end
          else begin
            add_counter <= add_counter + 1;
          end

          added_reg <= added_reg + din_store[add_counter];

        end

        SM_CLIP : begin
          if (added_reg > 2**(G_DWIDTH-1)-1) begin
            dout  <= 2**(G_DWIDTH-1)-1;
          end
          else if (added_reg < -(2**(G_DWIDTH-1))) begin
            dout  <= -(2**(G_DWIDTH-1));
          end
          else begin
            dout  <= added_reg;
          end

          dout_valid  <= 1;
          state       <= SM_SEND_OUTPUT;

        end

        SM_SEND_OUTPUT : begin
          if (dout_valid & dout_ready == 1) begin
            dout_valid  <= 0;
            din_ready   <= 1;
            state       <= SM_GET_INPUT;
          end
        end
      endcase
    end
  end

endmodule
