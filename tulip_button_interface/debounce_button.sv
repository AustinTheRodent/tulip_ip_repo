module debounce_button
(
  input  logic clk,
  input  logic aresetn,

  input logic unsigned [31:0] post_rising_edge_delay,   // clock cycles to wait after detecting a rising edge before allowing another edge detection
  input logic unsigned [31:0] post_falling_edge_delay,  // clock cycles to wait after detecting a falling edge before allowing another edge detection
  input logic unsigned [31:0] rising_edge_min_count,    // must see rising_edge_min_count samples of the same value to do a rising edge transition
  input logic unsigned [31:0] falling_edge_min_count,   // must see falling_edge_min_count samples of the same value to do a falling edge transition

  input  logic din_bounce,
  output logic dout_debounced
);

  typedef enum
  {
    SM_INIT,
    SM_GET_STARTING_STATE,
    SM_IS_DEASSERTED,
    SM_IS_ASSERTED,
    SM_DELAY_RISING_EDGE,
    SM_DELAY_FALLING_EDGE
  } state_t;
  state_t state;

  logic unsigned [31:0] delay_counter;
  logic unsigned [31:0] min_count_counter;

  /////////////////////////////////////////////////////////////

  always @ (posedge clk) begin
    if (aresetn == 0) begin
      dout_debounced  <= 0;
      state           <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin
          state <= SM_GET_STARTING_STATE;
        end

        SM_GET_STARTING_STATE : begin
          if (din_bounce == 0) begin
            dout_debounced  <= 0;
            state           <= SM_IS_DEASSERTED;
          end
          else begin
            dout_debounced  <= 1;
            state           <= SM_IS_ASSERTED;
          end
          min_count_counter <= 0;
        end

        SM_IS_DEASSERTED : begin
          if (din_bounce == 1) begin
            if (min_count_counter == rising_edge_min_count-1) begin
              dout_debounced    <= 1;
              min_count_counter <= 0;
              delay_counter     <= 0;
              state             <= SM_DELAY_RISING_EDGE;
            end
            else begin
              min_count_counter <= min_count_counter + 1;
            end
          end
          else begin
            min_count_counter   <= 0;
          end
        end

        SM_IS_ASSERTED : begin
          if (din_bounce == 0) begin
            if (min_count_counter == falling_edge_min_count-1) begin
              dout_debounced    <= 0;
              min_count_counter <= 0;
              delay_counter     <= 0;
              state             <= SM_DELAY_FALLING_EDGE;
            end
            else begin
              min_count_counter <= min_count_counter + 1;
            end
          end
          else begin
            min_count_counter   <= 0;
          end
        end

        SM_DELAY_RISING_EDGE : begin
          if (delay_counter == post_rising_edge_delay-1) begin
            state         <= SM_IS_ASSERTED;
          end
          else begin
            delay_counter <= delay_counter + 1;
          end
        end

        SM_DELAY_FALLING_EDGE : begin
          if (delay_counter == post_falling_edge_delay-1) begin
            state         <= SM_IS_DEASSERTED;
          end
          else begin
            delay_counter <= delay_counter + 1;
          end
        end

        default : begin
        end

      endcase
    end
  end

endmodule
