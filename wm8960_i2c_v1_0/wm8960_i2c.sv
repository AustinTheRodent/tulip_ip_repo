module wm8960_i2c
#(
  parameter int G_CLK_DIVIDER = 10
)
(
  input  logic        clk,
  input  logic        reset,
  input  logic        enable,

  input  logic [6:0]  din_device_address,
  input  logic        din_rd_wr,
  input  logic [6:0]  din_register_address,
  input  logic [8:0]  din_register_data,
  input  logic        din_valid,
  output logic        din_ready,

  inout  logic        i2c_sda,
  output logic        i2c_sclk,

  output logic [8:0]  dout_register_data,
  output logic [2:0]  dout_acks_received,
  output logic        dout_valid,
  input  logic        dout_ready
)

  logic sda_is_output;
  logic i2c_sda_output;

  logic [7:0] transaction_stage;

  typedef enum
  {
    SM_init,
    SM_get_input,
    SM_start_transaction,
    SM_send_device_address,
    SM_send_rd_wr_bit,
    SM_send_register_address,
    SM_get_register_data_0,
    SM_get_register_data_N,
    SM_send_register_data_0,
    SM_send_register_data_N,
    SM_delay,
    SM_get_ack,
    SM_end_transaction,
    SM_output
  } state_t;
  state_t state;
  state_t next_state;

  logic unsigned [15:0] clk_delay_amount;
  logic unsigned [15:0] clk_divider_counter;
  logic unsigned [7:0] byte_counter;

  logic unsigned [7:0] ack_counter;

  localparam int C_DEV_ADDR_WIDTH = $bits(din_device_address);
  localparam int C_REG_ADDR_WIDTH = $bits(din_register_address);
  localparam int C_REG_DATA_WIDTH = $bits(din_register_data);

  input  logic [6:0]  device_address_store;
  input  logic        rd_wr_store;
  input  logic [6:0]  register_address_store;
  input  logic [8:0]  register_data_store;

  ////////////////////////////////////////////////////////////////

  always_comb begin
    if ( sda_is_output == 1 ) begin
      i2c_sda  <= i2c_sda_output;
    end
    else begin
      i2c_sda  <= 1'bz;
    end
  end

  always @ (posedge clk) begin
    if ( reset == 1 || enable == 0 ) begin

      din_ready               <= 0;
      dout_valid              <= 0;
      sda_is_output           <= 1;
      i2c_sda_output          <= 1;
      i2c_sclk                <= 1;
      clk_divider_counter     <= 0;
      clk_delay_amount        <= 0;
      byte_counter            <= 0;
      ack_counter             <= 0;
      transaction_stage       <= 0;

      state                   <= SM_init;
      next_state              <= SM_init;
    end
    else begin
      case (state)
        SM_init : begin
          din_ready       <= 1;
          sda_is_output   <= 1;
          i2c_sda_output  <= 1;
          i2c_sclk        <= 1;

          state           <= SM_get_input;
        end

        SM_get_input : begin
          if ( din_valid == 1 && din_ready == 1 ) begin
            device_address_store    <= din_device_address;
            rd_wr_store             <= din_rd_wr;
            register_address_store  <= din_register_address;
            register_data_store     <= din_register_data;
            transaction_stage       <= 0;
            sda_is_output           <= 1;
            i2c_sda_output          <= 1;
            i2c_sclk                <= 1;
            din_ready               <= 0;
            state                   <= SM_start_transaction;
          end
        end

        SM_start_transaction : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= 1;
            i2c_sclk          <= 1;
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_start_transaction;
          end
          else if ( transaction_stage == 1 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= 0;
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_start_transaction;
          end
          else begin
            sda_is_output     <= 1;
            i2c_sda_output    <= 0;
            i2c_sclk          <= 0;
            transaction_stage <= 0;
            state             <= SM_send_device_address;
            next_state        <= SM_send_device_address;
          end
        end

        SM_end_transaction : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= 0;
            i2c_sclk          <= 0;
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_end_transaction;
          end
          else if ( transaction_stage == 1 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= 0;
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_end_transaction;
          end
          else begin
            sda_is_output     <= 1;
            i2c_sda_output    <= 1;
            i2c_sclk          <= 1;
            transaction_stage <= 0;
            dout_valid        <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_output;
          end
        end

        SM_send_device_address : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= device_address_store[C_DEV_ADDR_WIDTH-byte_counter-1];
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_device_address;
          end
          else if ( transaction_stage == 1 ) begin
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_device_address;
          end
          else
            i2c_sclk          <= 0;
            transaction_stage <= 0;
            if ( byte_counter == C_DEV_ADDR_WIDTH-1 ) begin
              byte_counter  <= 0;
              state         <= SM_send_rd_wr_bit;
            end
            else begin
              byte_counter  <= byte_counter + 1;
            end
          end
        end

        SM_send_rd_wr_bit : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= rd_wr_store;
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_rd_wr_bit;
          end
          else if ( transaction_stage == 1 ) begin
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_rd_wr_bit;
          end
          else
            i2c_sclk          <= 0;
            transaction_stage <= 0;
            state             <= SM_get_ack;
          end
        end

        SM_send_register_address : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= register_address_store[C_REG_ADDR_WIDTH-byte_counter-1];
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_register_address;
          end
          else if ( transaction_stage == 1 ) begin
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_register_address;
          end
          else
            i2c_sclk          <= 0;
            transaction_stage <= 0;
            if ( byte_counter == C_REG_ADDR_WIDTH-1 ) begin
              byte_counter  <= 0;
              if ( rd_wr_store == 0 ) begin
                state     <= SM_send_register_data_0;
              end
              else begin
                state     <= SM_get_register_data_0;
              end
            end
            else begin
              byte_counter  <= byte_counter + 1;
            end
          end
        end

        SM_get_register_data_0 : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 0;
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_0;
          end
          else if ( transaction_stage == 1 ) begin
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER/2;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_0;
          end
          else if ( transaction_stage == 2 ) begin
            dout_register_data[C_REG_DATA_WIDTH-byte_counter-1] <= i2c_sda;
            transaction_stage <= 3;
            clk_delay_amount  <= G_CLK_DIVIDER/2;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_0;
          end
          else
            i2c_sclk          <= 0;
            transaction_stage <= 0;
            byte_counter      <= byte_counter + 1;
            state             <= SM_get_ack;
          end
        end

        SM_get_register_data_N : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 0;
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_N;
          end
          else if ( transaction_stage == 1 ) begin
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER/2;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_N;
          end
          else if ( transaction_stage == 2 ) begin
            dout_register_data[C_REG_DATA_WIDTH-byte_counter-1] <= i2c_sda;
            transaction_stage <= 3;
            clk_delay_amount  <= G_CLK_DIVIDER/2;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_N;
          end
          else
            i2c_sclk          <= 0;
            transaction_stage <= 0;
            if ( byte_counter == C_REG_DATA_WIDTH-1 ) begin
              byte_counter  <= 0;
              state         <= SM_get_ack;
            end
            else begin
              byte_counter  <= byte_counter + 1;
            end
          end
        end

        SM_send_register_data_0 : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= register_data_store[C_REG_DATA_WIDTH-byte_counter-1];
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_0;
          end
          else if ( transaction_stage == 1 ) begin
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_0;
          end
          else
            i2c_sclk          <= 0;
            transaction_stage <= 0;
            byte_counter      <= byte_counter + 1;
            state             <= SM_get_ack;
          end
        end

        SM_send_register_data_N : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 1;
            i2c_sda_output    <= register_address_store[C_REG_DATA_WIDTH-byte_counter-1];
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_N;
          end
          else if ( transaction_stage == 1 ) begin
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_send_register_data_N;
          end
          else
            i2c_sclk          <= 0;
            transaction_stage <= 0;
            if ( byte_counter == C_REG_DATA_WIDTH-1 ) begin
              byte_counter  <= 0;
              state         <= SM_get_ack;
            end
            else begin
              byte_counter  <= byte_counter + 1;
            end
          end
        end

        SM_get_ack : begin
          if ( transaction_stage == 0 ) begin
            sda_is_output     <= 0;
            transaction_stage <= 1;
            clk_delay_amount  <= G_CLK_DIVIDER;
            state             <= SM_delay;
            next_state        <= SM_get_ack;
          end
          else if ( transaction_stage == 1 ) begin
            i2c_sclk          <= 1;
            transaction_stage <= 2;
            clk_delay_amount  <= G_CLK_DIVIDER/2;
            state             <= SM_delay;
            next_state        <= SM_get_ack;
          end
          else if ( transaction_stage == 2 ) begin
            dout_acks_received[ack_counter] <= ~i2c_sda;
            transaction_stage <= 3;
            clk_delay_amount  <= G_CLK_DIVIDER/2;
            state             <= SM_delay;
            next_state        <= SM_get_ack;
          end
          else
            i2c_sclk          <= 0;
            transaction_stage <= 0;

            if ( ack_counter == 0 ) begin
              ack_counter <= 1;
              state       <= SM_send_register_address;
            end
            else if ( ack_counter == 1 ) begin
              ack_counter <= 2;
              if ( rd_wr_store == 0 ) begin
                state     <= SM_send_register_data_N;
              end
              else begin
                state     <= SM_get_register_data_N;
              end
            end
            else begin
              ack_counter <= 0;
              state       <= SM_end_transaction;
            end

          begin
        end

        SM_delay : begin
          if ( clk_divider_counter == clk_delay_amount-1 ) begin
            clk_divider_counter <= 0;
            state               <= next_state;
          end
          else begin
            clk_divider_counter <= clk_divider_counter + 1;
          end
        end

        SM_output : begin
          if (  == 1 && dout_ready == 1 ) begin
            dout_valid  <= 0;
            state       <= SM_get_input
          end
        end

        default : begin
        end

      endcase
    end
  end

endmodule
