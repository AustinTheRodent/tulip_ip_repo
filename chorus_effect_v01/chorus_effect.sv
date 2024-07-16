module chorus_effect
#(
  parameter  int  G_DWIDTH = 24,
  localparam int  C_PROG_DDS_DWIDTH = 32,
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

  input  logic [C_PROG_DDS_DWIDTH-1:0]    prog_lfo_freq_din,
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
    SM_BUFFER_INPUT,
    SM_GET_LFO_INDEX,
    SM_GET_RD_INDEX0_1,
    SM_GET_FRACT,
    SM_RD_0,
    SM_RD_1,
    SM_MULT_FRACT,
    SM_APPLY_GAIN,
    SM_SEND_OUTPUT
  } state_t;
  state_t state;

  logic [G_DWIDTH-1:0]          prog_gain     [0:1];
  logic [C_PROG_DDS_DWIDTH-1:0] prog_avg_delay;
  logic [C_PROG_DDS_DWIDTH-1:0] prog_lfo_depth;
  logic [C_PROG_DDS_DWIDTH-1:0] prog_lfo_freq;

  logic [C_BUFFER_ADDDR_WIDTH-1:0]  bram_din_wr_addr;
  logic [C_BUFFER_ADDDR_WIDTH-1:0]  bram_din_rd_addr;
  logic [G_DWIDTH-1:0]              bram_din_data;
  logic                             bram_din_rd_valid;
  logic                             bram_din_wr_valid;

  logic [G_DWIDTH-1:0]              bram_dout_data;
  logic [G_DWIDTH-1:0]              bram_dout_rd_valid;


  logic [C_PROG_DDS_DWIDTH-1:0]                       dds_din;
  logic                                               dds_din_valid;
  logic                                               dds_din_ready;
  logic [C_PROG_DDS_DWIDTH-1:0]                       dds_dout;
  logic                                               dds_dout_valid;
  logic                                               dds_dout_ready;
  logic [C_PROG_DDS_DWIDTH+C_BUFFER_ADDDR_WIDTH-1:0]  dds_dout_mult;
  logic [C_PROG_DDS_DWIDTH+C_BUFFER_ADDDR_WIDTH-1:0]  dds_dout_mult_buff;
  logic                                               dds_dout_mult_valid;

  logic [C_BUFFER_ADDDR_WIDTH-1:0]                    lfo_index;
  logic [C_PROG_DDS_DWIDTH-1:0]                       fract;
  logic [C_PROG_DDS_DWIDTH+1-1:0]                     fract_0;
  logic [C_PROG_DDS_DWIDTH+1-1:0]                     fract_1;

  logic [C_BUFFER_ADDDR_WIDTH-1:0]                    rd_index0;
  logic [C_BUFFER_ADDDR_WIDTH-1:0]                    rd_index1;

  logic [G_DWIDTH-1:0]                                rd_0;
  logic [G_DWIDTH-1:0]                                rd_1;

  logic [G_DWIDTH+C_PROG_DDS_DWIDTH+1-1:0]            fract_mult_0;
  logic [G_DWIDTH+C_PROG_DDS_DWIDTH+1-1:0]            fract_mult_1;
  logic [G_DWIDTH+C_PROG_DDS_DWIDTH+1-1:0]            fract_mult_output;
  logic [G_DWIDTH-1:0]                                fract_mult_output_short;
  logic [G_DWIDTH+C_PROG_DDS_DWIDTH-1:0]              fract_mult_din_valid;
  logic [G_DWIDTH+C_PROG_DDS_DWIDTH-1:0]              fract_mult_dout_valid;

  logic [G_DWIDTH-1:0]                                din_store;

  logic [2*G_DWIDTH-1:0]  transparent_gain;
  logic [2*G_DWIDTH-1:0]  chorus_gain;
  logic                   gain_mult_din_valid;
  logic                   gain_mult_dout_valid;

  logic bram_clear_done;

  logic din_ready_int;
  logic [G_DWIDTH-1:0] dout_int;
  logic dout_valid_int;

//////////////////////////////////////////

  assign din_ready = (bypass == 0) ? din_ready_int : dout_ready;
  assign dout = (bypass == 0) ? dout_int : din;
  assign dout_valid = (bypass == 0) ? dout_valid_int : din_valid;

  always @ (posedge clk) begin

    logic [3:0] prog_gain_counter;
    logic [3:0] delay_counter;
    logic all_prog_done;

    if (reset == 1 || enable == 0) begin
      din_ready_int             <= 0;
      dout_valid_int            <= 0;
      delay_counter             <= 0;
      prog_gain_din_ready       <= 0;
      prog_gain_din_done        <= 0;
      prog_avg_delay_din_ready  <= 0;
      prog_avg_delay_din_done   <= 0;
      prog_lfo_depth_din_ready  <= 0;
      prog_lfo_depth_din_done   <= 0;
      prog_lfo_freq_din_ready   <= 0;
      prog_lfo_freq_din_done    <= 0;
      all_prog_done             <= 0;
      prog_gain_counter         <= 0;
      dds_din_valid             <= 0;
      bram_din_rd_valid         <= 0;
      bram_din_wr_addr          <= 0;
      bram_din_wr_valid         <= 1;
      fract_mult_din_valid      <= 0;
      gain_mult_din_valid       <= 0;
      bram_clear_done           <= 0;
      state                     <= SM_INIT;
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

          if (bram_clear_done == 0) begin
            if (bram_din_wr_addr == 2**C_BUFFER_ADDDR_WIDTH-1) begin
              bram_clear_done   <= 1;
              bram_din_wr_addr  <= 0;
            end
            else begin
              bram_din_wr_addr  <= bram_din_wr_addr + 1;
            end
          end

          if (prog_gain_din_valid & prog_gain_din_ready == 1) begin

            prog_gain[prog_gain_counter] <= prog_gain_din;

            if (prog_gain_counter == 1) begin
              prog_gain_din_ready  <= 0;
              prog_gain_din_done   <= 1;
            end
            else begin
              prog_gain_counter    <= prog_gain_counter + 1;
            end
          end

          if (prog_avg_delay_din_valid & prog_avg_delay_din_ready == 1) begin

            prog_avg_delay            <= prog_avg_delay_din;
            prog_avg_delay_din_ready  <= 0;
            prog_avg_delay_din_done   <= 1;

          end

          if (prog_lfo_depth_din_valid & prog_lfo_depth_din_ready == 1) begin

            prog_lfo_depth            <= prog_lfo_depth_din;
            prog_lfo_depth_din_ready  <= 0;
            prog_lfo_depth_din_done   <= 1;

          end

          if (prog_lfo_freq_din_valid & prog_lfo_freq_din_ready == 1) begin

            prog_lfo_freq           <= prog_lfo_freq_din;
            prog_lfo_freq_din_ready <= 0;
            prog_lfo_freq_din_done  <= 1;

          end

          if
          (
            bram_clear_done &
            prog_gain_din_done &
            prog_avg_delay_din_done &
            prog_lfo_depth_din_done &
            prog_lfo_freq_din_done == 1
          ) begin
            all_prog_done     <= 1;
            bram_din_wr_valid <= 1;
            din_ready_int     <= 1;
            state             <= SM_BUFFER_INPUT;
          end

        end

        SM_BUFFER_INPUT : begin
          if (din_valid & din_ready_int == 1) begin
            din_ready_int     <= 0;
            din_store         <= din;
            //bram_din_wr_addr  <= bram_din_wr_addr + 1;
            //bram_din_data     <= din;
            bram_din_wr_valid <= 0;
            dds_din_valid     <= 1;
            state             <= SM_GET_LFO_INDEX;
          end
        end

        SM_GET_LFO_INDEX : begin
          dds_din_valid <= 0;
          if (dds_dout_mult_valid == 1) begin
            {lfo_index, fract} <= dds_dout_mult;
            dds_dout_mult_buff <= dds_dout_mult;
            state <= SM_GET_RD_INDEX0_1;
          end
        end

        SM_GET_RD_INDEX0_1 : begin
          rd_index0 <= bram_din_wr_addr-prog_avg_delay+lfo_index;
          rd_index1 <= bram_din_wr_addr-prog_avg_delay+lfo_index+1;
          state     <= SM_GET_FRACT;
        end

        SM_GET_FRACT : begin
          fract_0 <= 2**32 - unsigned'(signed'(dds_dout_mult_buff) - (signed'(lfo_index) <<< C_PROG_DDS_DWIDTH));
          fract_1 <= signed'(dds_dout_mult_buff) - (signed'(lfo_index) <<< C_PROG_DDS_DWIDTH);
          bram_din_rd_addr  <= rd_index0;
          bram_din_rd_valid <= 1;
          state             <= SM_RD_0;
        end

        SM_RD_0 : begin
          if (bram_dout_rd_valid) begin
            bram_din_rd_addr  <= rd_index1;
            rd_0              <= bram_dout_data;
            bram_din_rd_valid <= 1;
            state             <= SM_RD_1;
          end
          else begin
            bram_din_rd_valid <= 0;
          end
        end

        SM_RD_1 : begin
          bram_din_rd_valid       <= 0;
          if (bram_dout_rd_valid) begin
            rd_1                  <= bram_dout_data;
            fract_mult_din_valid  <= 1;
            state                 <= SM_MULT_FRACT;
          end
        end

        SM_MULT_FRACT : begin
          fract_mult_din_valid  <= 0;
          if (fract_mult_dout_valid == 1) begin
            fract_mult_output   <= signed'(fract_mult_0 + fract_mult_1) >>> C_PROG_DDS_DWIDTH;
            gain_mult_din_valid <= 1;
            state               <= SM_APPLY_GAIN;
          end
        end

        SM_APPLY_GAIN : begin
          gain_mult_din_valid <= 0;
          if (gain_mult_dout_valid) begin
            dout_int        <= (signed'(chorus_gain) >>> (G_DWIDTH-2)) + (signed'(transparent_gain) >>> (G_DWIDTH-2));
            dout_valid_int  <= 1;
            state           <= SM_SEND_OUTPUT;
          end
        end

        SM_SEND_OUTPUT : begin
          if (dout_valid_int & dout_ready == 1) begin
            dout_valid_int    <= 0;
            din_ready_int     <= 1;
            bram_din_wr_addr  <= bram_din_wr_addr + 1;
            bram_din_wr_valid <= 1;
            state             <= SM_BUFFER_INPUT;
          end
        end

      endcase
    end
  end

  assign fract_mult_output_short = fract_mult_output[G_DWIDTH-1 -: G_DWIDTH];

  always @ (posedge clk) begin
    fract_mult_0 <= signed'(rd_0) * signed'({0,fract_0});
    fract_mult_1 <= signed'(rd_1) * signed'({0,fract_1});
    fract_mult_dout_valid <= fract_mult_din_valid;
  end

  always @ (posedge clk) begin
    //transparent_gain      <= signed'(din_store) * unsigned'(prog_gain[0]);
    //chorus_gain           <= signed'(fract_mult_output_short) * unsigned'(prog_gain[1]);
    transparent_gain      <= signed'(din_store) * signed'({0,prog_gain[0]});
    chorus_gain           <= signed'(fract_mult_output_short) * signed'({0,prog_gain[1]});
    gain_mult_dout_valid  <= gain_mult_din_valid;
  end

  assign bram_din_data = (bram_clear_done == 1) ? din : 0;

  chorus_bram
  #(
    .G_BRAM_ADDRWIDTH (C_BUFFER_ADDDR_WIDTH),
    .G_DWIDTH         (G_DWIDTH)
  )
  u_chorus_bram
  (
    .clk              (clk),

    .din_wr_addr      (bram_din_wr_addr),
    .din_rd_addr      (bram_din_rd_addr),
    .din_data         (bram_din_data),
    .din_rd_valid     (bram_din_rd_valid),
    .din_wr_valid     (bram_din_wr_valid),

    .dout_data        (bram_dout_data),
    .dout_rd_valid    (bram_dout_rd_valid)
  );


  assign dds_din = prog_lfo_freq;

  dds_taylor
  #(
    .G_DIN_WIDTH      (C_PROG_DDS_DWIDTH),
    .G_DOUT_WIDTH     (C_PROG_DDS_DWIDTH),
    .G_COMPLEX_OUTPUT ()
  )
  u_dds_lfo
  (
    .clk              (clk),
    .reset            (reset),
    .enable           (enable),

    .din              (dds_din),
    .din_valid        (dds_din_valid),
    .din_ready        (dds_din_ready),

    .dout_re          (dds_dout),
    .dout_im          (),
    .dout_valid       (dds_dout_valid),
    .dout_ready       (dds_dout_ready)
  );

  assign dds_dout_ready = 1;

  always @ (posedge clk) begin
    dds_dout_mult       <= signed'(dds_dout) * signed'({0,prog_lfo_depth});
    dds_dout_mult_valid <= dds_dout_valid;
  end



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
