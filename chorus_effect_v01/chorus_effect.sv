module chorus_effect
#(
  parameter int   G_NUM_CHORUS_CHANNELS = 4,
  localparam int  G_DWIDTH = 24,
  localparam int  C_PROG_CHIRP_DWIDTH = 32,
  localparam int  C_BUFFER_ADDDR_WIDTH = 12
)
(
  input  logic                            clk,
  input  logic                            reset,
  input  logic                            enable,
  input  logic                            bypass,

  input  logic [G_DWIDTH-1:0]             prog_gain_din, // fixed point, 2 integer bits
  input  logic                            prog_gain_din_valid,
  output logic                            prog_gain_din_ready,
  output logic                            prog_gain_din_done,

  input  logic [C_BUFFER_ADDDR_WIDTH-1:0] prog_avg_delay_din,
  input  logic                            prog_avg_delay_din_valid,
  output logic                            prog_avg_delay_din_ready,
  output logic                            prog_avg_delay_din_done,

  input  logic [C_BUFFER_ADDDR_WIDTH-1:0] prog_lfo_depth_din,
  input  logic                            prog_lfo_depth_din_valid,
  output logic                            prog_lfo_depth_din_ready,
  output logic                            prog_lfo_depth_din_done,

  input  logic [C_PROG_CHIRP_DWIDTH-1:0]  prog_lfo_freq_din,
  input  logic                            prog_lfo_freq_din_valid,
  output logic                            prog_lfo_freq_din_ready,
  output logic                            prog_lfo_freq_din_done,

  input  logic [G_DWIDTH-1:0]             din,
  input  logic                            din_valid,
  output logic                            din_ready,

  output logic [G_DWIDTH-1:0]             dout,
  output logic                            dout_valid,
  input  logic                            dout_ready
);

  typedef enum
  {
    SM_INIT,
    SM_PROGRAM,
    SM_RUN
  } state_t;
  state_t state;

  logic [G_DWIDTH-1:0]            prog_gain       [0:G_NUM_CHORUS_CHANNELS];
  logic [C_PROG_CHIRP_DWIDTH-1:0] prog_avg_delay  [0:G_NUM_CHORUS_CHANNELS-1];
  logic [C_PROG_CHIRP_DWIDTH-1:0] prog_lfo_depth  [0:G_NUM_CHORUS_CHANNELS-1];
  logic [C_PROG_CHIRP_DWIDTH-1:0] prog_lfo_freq   [0:G_NUM_CHORUS_CHANNELS-1];

//////////////////////////////////////////

  always @ (posedge clk) begin

    logic [$clog2(G_NUM_CHORUS_CHANNELS)+1:0] prog_gain_counter;
    logic [$clog2(G_NUM_CHORUS_CHANNELS):0]   prog_avg_delay_counter;
    logic [$clog2(G_NUM_CHORUS_CHANNELS):0]   prog_lfo_depth_counter;
    logic [$clog2(G_NUM_CHORUS_CHANNELS):0]   prog_lfo_freq_counter;
    logic [3:0] delay_counter;

    if (reset == 1 || enable == 0) begin
      delay_counter               <= 0;

      prog_gain_din_ready         <= 0;
      prog_gain_din_done          <= 0;

      prog_avg_delay_din_ready    <= 0;
      prog_avg_delay_din_done     <= 0;

      prog_lfo_depth_din_ready    <= 0;
      prog_lfo_depth_din_done     <= 0;

      prog_lfo_freq_din_ready     <= 0;
      prog_lfo_freq_din_done      <= 0;

      all_prog_done               <= 0;

      prog_gain_counter           <= 0;
      prog_avg_delay_counter      <= 0;
      prog_lfo_depth_counter      <= 0;
      prog_lfo_freq_counter       <= 0;
      state                       <= SM_INIT;
    end
    else begin
      case (state)
        SM_INIT : begin
          if (delay_counter == 7) begin

            prog_gain_din_ready         <= 1;
            prog_avg_delay_din_ready    <= 1;
            prog_lfo_depth_din_ready    <= 1;
            prog_lfo_freq_din_ready     <= 1;

            state                       <= SM_PROGRAM;
          end
          else begin
            delay_counter               <= delay_counter + 1;
          end
        end

        SM_PROGRAM : begin

          if (prog_gain_din_valid & prog_gain_din_ready == 1) begin

            prog_gain[prog_gain_counter] <= prog_gain_din;

            if (prog_gain_counter == G_NUM_CHORUS_CHANNELS) begin
              prog_gain_din_ready  <= 0;
              prog_gain_din_done   <= 1;
            end
            else begin
              prog_gain_counter    <= prog_gain_counter + 1;
            end
          end

          if (prog_avg_delay_din_valid & prog_avg_delay_din_ready == 1) begin

            prog_avg_delay[prog_avg_delay_counter] <= prog_avg_delay_din;

            if (prog_avg_delay_counter == G_NUM_CHORUS_CHANNELS-1) begin
              prog_avg_delay_din_ready    <= 0;
              prog_avg_delay_din_done   <= 1;
            end
            else begin
              prog_avg_delay_counter      <= prog_avg_delay_counter + 1;
            end
          end

          if (prog_lfo_depth_din_valid & prog_lfo_depth_din_ready == 1) begin

            prog_lfo_depth[prog_lfo_depth_counter] <= prog_lfo_depth_din;

            if (prog_lfo_depth_counter == G_NUM_CHORUS_CHANNELS-1) begin
              prog_lfo_depth_din_ready <= 0;
              prog_lfo_depth_din_done  <= 1;
            end
            else begin
              prog_lfo_depth_counter    <= prog_lfo_depth_counter + 1;
            end
          end

          if (prog_lfo_freq_din_valid & prog_lfo_freq_din_ready == 1) begin

            prog_lfo_freq[prog_lfo_freq_counter] <= prog_lfo_freq_din;

            if (prog_lfo_freq_counter == G_NUM_CHORUS_CHANNELS-1) begin
              prog_lfo_freq_din_ready  <= 0;
              prog_lfo_freq_din_done   <= 1;
            end
            else begin
              prog_lfo_freq_counter       <= prog_lfo_freq_counter + 1;
            end
          end

          if
          (
            prog_gain_din_done &
            prog_avg_delay_din_done &
            prog_lfo_depth_din_done &
            prog_lfo_freq_din_done == 1
          ) begin
            all_prog_done  <= 1;
            state          <= SM_RUN;
          end

        end

        SM_RUN : begin
        end
      endcase
    end
  end

  chorus_bram
  #(
    .G_BRAM_ADDRWIDTH (C_BUFFER_ADDDR_WIDTH),
    .G_DWIDTH         (G_DWIDTH)
  )
  u_chorus_bram
  (
    clk               (clk),

    din_wr_addr       (),
    din_rd_addr       (),
    din_data          (),
    din_rd_valid      (),
    din_wr_valid      (),

    dout_data         (),
    dout_rd_valid     ()
  );


endmodule

module chorus_bram
#(
  parameter int G_BRAM_ADDRWIDTH = 12,
  parameter int G_DWIDTH = 24
)
(
  input  logic clk,

  input  logic [G_BRAM_ADDRWIDTH-1:0] din_wr_addr,
  input  logic [G_BRAM_ADDRWIDTH-1:0] din_rd_addr,
  input  logic [G_DWIDTH-1:0]         din_data,
  input  logic                        din_rd_valid,
  input  logic                        din_wr_valid,

  output logic [G_DWIDTH-1:0]         dout_data,
  output logic                        dout_rd_valid
);

  logic [G_DWIDTH-1:0] bram_memory [0:2**G_BRAM_ADDRWIDTH-1];

  always @ (posedge clk) begin
    if (din_wr_valid == 1) begin
      bram_memory[din_wr_addr]  <= din_data;
    end
  end

  always @ (posedge clk) begin
    dout_data                   <= bram_memory[din_rd_addr];
    dout_rd_valid               <= din_rd_valid;
  end

endmodule
