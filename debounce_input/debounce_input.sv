module debounce_input
#(
  parameter int G_POST_RISING_EDGE_DELAY = 256, // clock cycles to wait after detecting a rising edge before allowing another edge detection
  parameter int G_POST_FALLING_EDGE_DELAY = 256, // clock cycles to wait after detecting a falling edge before allowing another edge detection
  parameter int G_RISING_EDGE_MIN_COUNT = 16, // must see G_RISING_EDGE_MIN_COUNT samples of the same value to do a rising edge transition
  parameter int G_FALLING_EDGE_MIN_COUNT = 16 // must see G_FALLING_EDGE_MIN_COUNT samples of the same value to do a falling edge transition
)
(
  input  logic clk,
  input  logic aresetn,

  input  logic din_bounce,
  output logic dout_debounced

);

  typedef enum
  {
    SM_INIT,
    SM_GET_STARTING_STATE,
    SM_IS_DEASSERTED,
    SM_IS_ASSERTED,
    SM_DELAY
  } state_t;
  state_t state;
  state_t next_state;


  always @ (posedge clk) begin
  end


endmodule
