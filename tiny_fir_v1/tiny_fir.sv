module tiny_fir
#(
  parameter int G_NUM_TAPS = 16,
  parameter int G_DATA_WIDTH = 16,
  parameter int G_TAP_WIDTH = 16,
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable,

  input  logic [G_TAP_WIDTH-1:0] tap_din,
  input  logic                   tap_din_valid,
  output logic                   tap_din_ready,
  output logic                   tap_din_done,

  input  logic [G_DATA_WIDTH-1:0]  din,
  input  logic                     din_valid,
  output logic                     din_ready,

  output logic [G_DATA_WIDTH-1:0]  dout,
  output logic                     dout_valid,
  input  logic                     dout_ready
);

  typedef enum
  {
    SM_INIT,
    SM_PROGRAM_TAPS,
    SM_GET_INPUT,
    SM_CALC,
    SM_RESCALE,
    SM_SEND_OUTPUT
  } state_t;
  state_t state;

  logic unsigned [$clog2(G_NUM_TAPS)-1:0] prog_tap_address;

  logic taps_bram_wr_accept;

  logic unsigned [$clog2(G_NUM_TAPS)-1:0] din_bram_start_addr;
  logic unsigned [$clog2(G_NUM_TAPS):0] din_bram_counter;
  logic unsigned [$clog2(G_NUM_TAPS)-1:0] din_bram_wr_din_addr;
  logic [G_DATA_WIDTH-1:0]                din_bram_wr_din_value;
  logic                                   din_bram_wr_din_valid;
  logic unsigned [$clog2(G_NUM_TAPS)-1:0] din_bram_rd_din_addr;
  logic                                   din_bram_rd_din_valid;
  logic [G_DATA_WIDTH-1:0]                din_bram_rd_dout_value;
  logic                                   din_bram_rd_dout_valid;

  logic unsigned [$clog2(G_NUM_TAPS)-1:0] taps_bram_rd_din_addr;
  logic                                   taps_bram_rd_din_valid;
  logic [G_TAP_WIDTH-1:0]                 taps_bram_rd_dout_value;
  logic                                   taps_bram_rd_dout_valid;

  logic signed [G_DATA_WIDTH+G_TAP_WIDTH-1:0] mult;
  logic mult_valid;

  logic signed [G_DATA_WIDTH+G_TAP_WIDTH+$clog2(G_NUM_TAPS)-1:0] accumulate;
  logic signed [G_DATA_WIDTH+G_TAP_WIDTH+$clog2(G_NUM_TAPS)-1:0] accumulate_rs;
  logic signed [G_DATA_WIDTH-1:0] accumulate_short;
  logic unsigned [$clog2(G_NUM_TAPS)-1:0] accumulate_counter;

//////////////////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      din_ready               <= 0;
      dout_valid              <= 0;
      taps_bram_rd_din_addr   <= 0;
      taps_bram_rd_din_valid  <= 0;
      din_bram_rd_din_valid   <= 0;
      tap_din_ready           <= 0;
      state                   <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin
          prog_tap_address      <= 0;
          din_bram_wr_din_addr  <= 0;
          din_bram_wr_din_value <= 0;
          din_bram_wr_din_valid <= 1;
          tap_din_ready         <= 1;
          state                 <= SM_PROGRAM_TAPS;
        end

        SM_PROGRAM_TAPS : begin
          if (tap_din_valid == 1 && tap_din_ready == 1) begin
            if (prog_tap_address == G_NUM_TAPS-1) begin
              din_ready             <= 1;
              din_bram_start_addr   <= 0;
              din_bram_wr_din_valid <= 0;
              tap_din_ready         <= 0;
              tap_din_done          <= 1;
              state                 <= SM_GET_INPUT;
            end
            else begin
              prog_tap_address      <= prog_tap_address + 1;
              din_bram_wr_din_addr  <= din_bram_wr_din_addr + 1;
            end
          end
        end

        SM_GET_INPUT : begin
          if (din_valid == 1 && din_ready == 1) begin
            din_bram_counter      <= 0;
            din_bram_wr_din_addr  <= din_bram_start_addr;
            din_bram_wr_din_value <= din;
            din_bram_wr_din_valid <= 1;
            accumulate            <= 0;
            accumulate_counter    <= 0;
            state                 <= SM_CALC;
          end
        end

        SM_CALC : begin
          din_bram_wr_din_valid <= 0;

          if (din_bram_counter == G_NUM_TAPS) begin
            taps_bram_rd_din_valid  <= 0;
            din_bram_rd_din_valid   <= 0;
          end
          else begin
            if (din_bram_start_addr-din_bram_counter < 0) begin
              din_bram_rd_din_addr  <= din_bram_start_addr-din_bram_counter+G_NUM_TAPS;
            end
            else begin
              din_bram_rd_din_addr  <= din_bram_start_addr-din_bram_counter;
            end
            taps_bram_rd_din_addr   <= din_bram_counter;
            din_bram_counter        <= din_bram_counter + 1;
            taps_bram_rd_din_valid  <= 1;
            din_bram_rd_din_valid   <= 1;
          end

          if (mult_valid == 1) begin
            if (accumulate_counter == G_NUM_TAPS-1) begin
              state             <= SM_RESCALE;
            end
            accumulate          <= accumulate + mult;
            accumulate_counter  <= accumulate_counter + 1;
          end

        end

        SM_RESCALE : begin
          accumulate_rs = accumulate >>> (G_TAP_WIDTH-1);
          if (accumulate_rs > 2**(G_DATA_WIDTH-1)-1) begin
            accumulate_short <= 2**(G_DATA_WIDTH-1)-1;
          end
          else if (accumulate_rs < -2**(G_DATA_WIDTH-1)) begin
            accumulate_short <= -2**(G_DATA_WIDTH-1);
          end
          else begin
            accumulate_short <= accumulate_rs[G_DATA_WIDTH-1 -: G_DATA_WIDTH];
          end
          state <= SM_SEND_OUTPUT;
        end

        SM_SEND_OUTPUT : begin
          dout <= accumulate_short;
          if (dout_valid == 1 && dout_ready == 1) begin
            dout_valid          <= 0;
            din_ready           <= 1;
            din_bram_start_addr <= din_bram_start_addr + 1;
            state               <= SM_GET_INPUT;
          end
          else begin
            dout_valid          <= 1;
          end
        end

        default : begin
        end

      endcase
    end
  end

  assign taps_bram_wr_accept = tap_din_valid & tap_din_ready;
  
  tiny_fir_bram
  #(
    .G_ADDR_WIDTH  ($clog2(G_NUM_TAPS)),
    .G_DATA_WIDTH  (G_TAP_WIDTH)
  )
  u_taps_bram
  (
    .clk            (clk),
  
    .wr_din_addr    (prog_tap_address),
    .wr_din_value   (tap_din),
    .wr_din_valid   (taps_bram_wr_accept),
  
    .rd_din_addr    (taps_bram_rd_din_addr),
    .rd_din_valid   (taps_bram_rd_din_valid),
  
    .rd_dout_value  (taps_bram_rd_dout_value),
    .rd_dout_valid  (taps_bram_rd_dout_valid)
  );

  tiny_fir_bram
  #(
    .G_ADDR_WIDTH  ($clog2(G_NUM_TAPS)),
    .G_DATA_WIDTH  (G_TAP_WIDTH)
  )
  u_din_bram
  (
    .clk            (clk),
  
    .wr_din_addr    (din_bram_wr_din_addr),
    .wr_din_value   (din_bram_wr_din_value),
    .wr_din_valid   (din_bram_wr_din_valid),
  
    .rd_din_addr    (din_bram_rd_din_addr),
    .rd_din_valid   (din_bram_rd_din_valid),
  
    .rd_dout_value  (din_bram_rd_dout_value),
    .rd_dout_valid  (din_bram_rd_dout_valid)
  );

  always @ (posedge clk) begin
    mult        <= signed'(taps_bram_rd_dout_value)*signed'(din_bram_rd_dout_value);
    mult_valid  <= din_bram_rd_dout_valid;
  end

endmodule

module tiny_fir_bram
#(
  parameter int G_ADDR_WIDTH,
  parameter int G_DATA_WIDTH
)
(
  input logic                     clk,

  input logic [G_ADDR_WIDTH-1:0]  wr_din_addr,
  input logic [G_DATA_WIDTH-1:0]  wr_din_value,
  input logic                     wr_din_valid,

  input logic [G_ADDR_WIDTH-1:0]  rd_din_addr,
  input logic                     rd_din_valid,

  output logic [G_DATA_WIDTH-1:0] rd_dout_value,
  output logic                    rd_dout_valid
);

  logic [G_DATA_WIDTH-1:0] bram_memory [0:2**G_ADDR_WIDTH-1];

  always @ (posedge clk) begin
    if (wr_din_valid == 1) begin
      bram_memory[wr_din_addr] <= wr_din_value;
    end
  end

  always @ (posedge clk) begin
    rd_dout_value <= bram_memory[rd_din_addr];
  end

  always @ (posedge clk) begin
    rd_dout_valid <= rd_din_valid;
  end

endmodule


