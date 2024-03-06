module configurable_fir
#(
  parameter int G_NUM_STAGES = 4, // must be power of 2?, probably not nessisary
  parameter int G_STAGE_DEPTH_LOG2 = 2,
  parameter int G_NUM_TAPS = 16,
  parameter int G_DATA_WIDTH = 16,
  parameter int G_TAP_WIDTH = 16
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable,

  input  logic [G_TAP_WIDTH-1:0]  tap_din,
  input  logic                    tap_din_valid,
  output logic                    tap_din_ready,
  output logic                    tap_din_done,

  input  logic [G_DATA_WIDTH-1:0] din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [G_DATA_WIDTH-1:0] dout,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  localparam int N = G_NUM_STAGES;
  localparam int M = 2**G_STAGE_DEPTH_LOG2;

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

//  logic taps_bram_wr_accept;
//
//  logic unsigned [$clog2(G_NUM_TAPS)-1:0] din_bram_start_addr;
//  logic unsigned [$clog2(G_NUM_TAPS):0] din_bram_counter;
//  logic unsigned [$clog2(G_NUM_TAPS)-1:0] din_bram_wr_din_addr;
//  logic [G_DATA_WIDTH-1:0]                din_bram_wr_din_value;
//  logic                                   din_bram_wr_din_valid;
//  logic unsigned [$clog2(G_NUM_TAPS)-1:0] din_bram_rd_din_addr;
//  logic                                   din_bram_rd_din_valid;
//  logic [G_DATA_WIDTH-1:0]                din_bram_rd_dout_value;
//  logic                                   din_bram_rd_dout_valid;
//
//  logic unsigned [$clog2(G_NUM_TAPS)-1:0] taps_bram_rd_din_addr;
//  logic                                   taps_bram_rd_din_valid;
//  logic [G_TAP_WIDTH-1:0]                 taps_bram_rd_dout_value;
//  logic                                   taps_bram_rd_dout_valid;
//
//  logic signed [G_DATA_WIDTH+G_TAP_WIDTH-1:0] mult;
//  logic mult_valid;
//
//  logic signed [G_DATA_WIDTH+G_TAP_WIDTH+$clog2(G_NUM_TAPS)-1:0] accumulate;
//  logic signed [G_DATA_WIDTH+G_TAP_WIDTH+$clog2(G_NUM_TAPS)-1:0] accumulate_rs;
//  logic signed [G_DATA_WIDTH-1:0] accumulate_short;
//  logic unsigned [$clog2(G_NUM_TAPS)-1:0] accumulate_counter;

  logic unsigned [$clog2(N)+$clog2(M)-1:0]  din_bram_start_addr [0:N-1];

  logic unsigned [$clog2(N)+$clog2(M)-1:0]  input_data_bram_wr_din_addr_full;
  logic unsigned [$clog2(N)-1:0]            input_data_bram_wr_din_addr_full_msbs;
  logic unsigned [$clog2(M)-1:0]            input_data_bram_wr_din_addr;
  logic [G_DATA_WIDTH-1:0]                  input_data_bram_wr_din_value;
  logic                                     input_data_bram_wr_din_valid_gate;
  logic                                     input_data_bram_wr_din_valid [0:N-1];

  logic unsigned [$clog2(N)+$clog2(M)-1:0]  input_data_bram_rd_din_addr_full;
  logic unsigned [$clog2(M)-1:0]            input_data_bram_rd_din_addr;
  logic                                     input_data_bram_rd_din_valid [0:N-1];
  logic [G_DATA_WIDTH-1:0]                  input_data_bram_rd_dout_value [0:N-1];
  logic                                     input_data_bram_rd_dout_valid [0:N-1];


  logic unsigned [$clog2(N)+$clog2(M)-1:0]  taps_bram_wr_din_addr_full;
  logic unsigned [$clog2(N)-1:0]            taps_bram_wr_din_addr_full_msbs;
  logic unsigned [$clog2(M)-1:0]            taps_bram_wr_din_addr;
  logic [G_TAP_WIDTH-1:0]                   taps_bram_wr_din_value;
  logic                                     taps_bram_wr_din_valid_gate;
  logic                                     taps_bram_wr_din_valid [0:N-1];

  logic unsigned [$clog2(N)+$clog2(M)-1:0]  taps_bram_rd_din_addr_full;
  logic unsigned [$clog2(M)-1:0]            taps_bram_rd_din_addr;
  logic                                     taps_bram_rd_din_valid [0:N-1];
  logic [G_TAP_WIDTH-1:0]                   taps_bram_rd_dout_value [0:N-1];
  logic                                     taps_bram_rd_dout_valid [0:N-1];

//////////////////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      //tap_din_done            <= 0;
      //din_ready               <= 0;
      //dout_valid              <= 0;
      //taps_bram_rd_din_addr   <= 0;
      //taps_bram_rd_din_valid  <= 0;
      //din_bram_rd_din_valid   <= 0;
      //tap_din_ready           <= 0;

      //input_data_bram_wr_din_addr_full <= 0;


      state                   <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin
          input_data_bram_wr_din_value      <= 0;
          tap_din_ready                     <= 1;

          taps_bram_wr_din_addr_full        <= 0;
          input_data_bram_wr_din_valid_gate <= 1;
          input_data_bram_wr_din_addr_full  <= 0;

          state                 <= SM_PROGRAM_TAPS;
        end

        SM_PROGRAM_TAPS : begin
          if (tap_din_valid == 1 && tap_din_ready == 1) begin
            if (prog_tap_address == G_NUM_TAPS-1) begin
              din_ready                         <= 1;

              input_data_bram_wr_din_valid_gate <= 0;
              tap_din_ready                     <= 0;
              tap_din_done                      <= 1;
              state                             <= SM_GET_INPUT;
            end
            else begin
              taps_bram_wr_din_addr_full        <= taps_bram_wr_din_addr_full + 1;
              input_data_bram_wr_din_addr_full  <= input_data_bram_wr_din_addr_full + 1;
            end
          end
        end

        SM_GET_INPUT : begin
          if (din_valid == 1 && din_ready == 1) begin
            din_ready             <= 0;
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
            if (din_bram_start_addr < din_bram_counter) begin
              din_bram_rd_din_addr  <= G_NUM_TAPS - (din_bram_counter - din_bram_start_addr);
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
            if (din_bram_start_addr == G_NUM_TAPS-1) begin
              din_bram_start_addr <= 0;
            end
            else begin
              din_bram_start_addr <= din_bram_start_addr + 1;
            end
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

  assign input_data_bram_wr_din_addr = input_data_bram_wr_din_addr_full[$clog2(M)-1 -: $clog2(M)];

  assign input_data_bram_wr_din_addr_full_msbs = input_data_bram_wr_din_addr_full[$clog2(N)+$clog2(M)-1 -: $clog2(N)];

  assign taps_bram_wr_din_addr_full_msbs = taps_bram_wr_din_addr_full[$clog2(N)+$clog2(M)-1 -: $clog2(N)];

  assign taps_bram_wr_din_valid_gate = tap_din_valid & tap_din_ready;

//  always_comb begin
//
//    for (int i = 0 ; i < N ; i++) begin
//      if (input_data_bram_wr_din_addr_full_msbs == i) begin
//        input_data_bram_wr_din_valid[i] = input_data_bram_wr_din_valid_gate;
//      end
//      else begin
//        input_data_bram_wr_din_valid[i] = 0;
//      end
//    end
//
//  end

  generate

    for (genvar i = 0 ; i < N ; i++) begin

      assign input_data_bram_wr_din_valid[i]  = (input_data_bram_wr_din_addr_full_msbs == i) ? input_data_bram_wr_din_valid_gate : 0;
      assign taps_bram_wr_din_valid[i]        = (taps_bram_wr_din_addr_full_msbs == i) ? taps_bram_wr_din_valid_gate : 0;

      config_fir_bram
      #(
        .G_ADDR_WIDTH  ($clog2(M)),
        .G_DATA_WIDTH  (G_DATA_WIDTH)
      )
      u_input_data_bram
      (
        .clk            (clk),

        .wr_din_addr    (input_data_bram_wr_din_addr),
        .wr_din_value   (input_data_bram_wr_din_value),
        .wr_din_valid   (input_data_bram_wr_din_valid[i]),

        .rd_din_addr    (input_data_bram_rd_din_addr),
        .rd_din_valid   (input_data_bram_rd_din_valid[i]),

        .rd_dout_value  (input_data_bram_rd_dout_value[i]),
        .rd_dout_valid  (input_data_bram_rd_dout_valid[i])
      );

      config_fir_bram
      #(
        .G_ADDR_WIDTH  ($clog2(M)),
        .G_DATA_WIDTH  (G_TAP_WIDTH)
      )
      u_taps_bram
      (
        .clk            (clk),

        .wr_din_addr    (taps_bram_wr_din_addr),
        .wr_din_value   (taps_bram_wr_din_value),
        .wr_din_valid   (taps_bram_wr_din_valid[i]),

        .rd_din_addr    (taps_bram_rd_din_addr),
        .rd_din_valid   (taps_bram_rd_din_valid[i]),

        .rd_dout_value  (taps_bram_rd_dout_value[i]),
        .rd_dout_valid  (taps_bram_rd_dout_valid[i])
      );

    end

  endgenerate


//  assign taps_bram_wr_accept = tap_din_valid & tap_din_ready;
//
//  config_fir_bram
//  #(
//    .G_ADDR_WIDTH  ($clog2(G_NUM_TAPS)),
//    .G_DATA_WIDTH  (G_TAP_WIDTH)
//  )
//  u_taps_bram
//  (
//    .clk            (clk),
//
//    .wr_din_addr    (prog_tap_address),
//    .wr_din_value   (tap_din),
//    .wr_din_valid   (taps_bram_wr_accept),
//
//    .rd_din_addr    (taps_bram_rd_din_addr),
//    .rd_din_valid   (taps_bram_rd_din_valid),
//
//    .rd_dout_value  (taps_bram_rd_dout_value),
//    .rd_dout_valid  (taps_bram_rd_dout_valid)
//  );
//
//  config_fir_bram
//  #(
//    .G_ADDR_WIDTH  ($clog2(G_NUM_TAPS)),
//    .G_DATA_WIDTH  (G_DATA_WIDTH)
//  )
//  u_din_bram
//  (
//    .clk            (clk),
//
//    .wr_din_addr    (din_bram_wr_din_addr),
//    .wr_din_value   (din_bram_wr_din_value),
//    .wr_din_valid   (din_bram_wr_din_valid),
//
//    .rd_din_addr    (din_bram_rd_din_addr),
//    .rd_din_valid   (din_bram_rd_din_valid),
//
//    .rd_dout_value  (din_bram_rd_dout_value),
//    .rd_dout_valid  (din_bram_rd_dout_valid)
//  );

  always @ (posedge clk) begin
    mult        <= signed'(taps_bram_rd_dout_value)*signed'(din_bram_rd_dout_value);
    mult_valid  <= din_bram_rd_dout_valid;
  end

endmodule

module config_fir_bram
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


