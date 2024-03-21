module configurable_fir
#(
  parameter int G_NUM_STAGES_LOG2 = 2,
  parameter int G_STAGE_DEPTH_LOG2 = 2,
  parameter int G_DATA_WIDTH = 16,
  parameter int G_TAP_WIDTH = 16,
  parameter int G_OUTPUT_UNSCALED = 0
)
(
  input  logic clk,
  input  logic reset,
  input  logic enable,
  input  logic bypass,

  input  logic [G_TAP_WIDTH-1:0]  tap_din,
  input  logic                    tap_din_valid,
  output logic                    tap_din_ready,
  output logic                    tap_din_done,

  input  logic [G_DATA_WIDTH-1:0] din,
  input  logic                    din_valid,
  output logic                    din_ready,

  output logic [G_DATA_WIDTH+(M_LOG2+N_LOG2+G_TAP_WIDTH)*G_OUTPUT_UNSCALED-1:0] dout,
  output logic                    dout_valid,
  input  logic                    dout_ready
);

  localparam int N = 2**G_NUM_STAGES_LOG2;
  localparam int M = 2**G_STAGE_DEPTH_LOG2;

  localparam int N_LOG2 = G_NUM_STAGES_LOG2;
  localparam int M_LOG2 = G_STAGE_DEPTH_LOG2;

  typedef enum
  {
    SM_INIT,
    SM_PROGRAM_TAPS,
    SM_GET_INPUT,
    SM_CALC,
    //SM_RESIZE,
    SM_ADD2,
    SM_RESIZE2,
    SM_OUTPUT
  } state_t;

  state_t state;

  logic [G_DATA_WIDTH-1:0] brm_din;

  logic                     brm_din_rd_din_valid_gate;
  logic [M_LOG2-1:0]        brm_din_wr_din_addr;
  logic [G_DATA_WIDTH-1:0]  brm_din_wr_din_value  [0:N-1];
  logic                     brm_din_wr_din_valid;
  logic [M_LOG2-1:0]        brm_din_rd_din_addr;
  logic                     brm_din_rd_din_valid;
  logic [G_DATA_WIDTH-1:0]  brm_din_rd_dout_value [0:N-1];
  logic                     brm_din_rd_dout_valid [0:N-1];

  logic [N_LOG2-1:0]        brm_taps_wr_din_bank_counter;
  logic [M_LOG2-1:0]        brm_taps_wr_din_addr;
  logic [G_TAP_WIDTH-1:0]   brm_taps_wr_din_value;
  logic                     brm_taps_wr_din_valid  [0:N-1];
  logic [M_LOG2-1:0]        brm_taps_rd_din_addr;
  logic                     brm_taps_rd_din_valid  [0:N-1];
  logic [G_DATA_WIDTH-1:0]  brm_taps_rd_dout_value [0:N-1];
  logic                     brm_taps_rd_dout_valid [0:N-1];

  logic unsigned [N_LOG2+M_LOG2-1:0] program_counter;

  logic [G_DATA_WIDTH-1:0] registered_bram_data [0:N-2];

  logic signed [M_LOG2+G_DATA_WIDTH+G_TAP_WIDTH-1:0]  accumulate        [0:N-1];
  logic signed [M_LOG2+G_DATA_WIDTH+G_TAP_WIDTH-1:0]  accumulate_rs     [0:N-1];
  logic signed [G_DATA_WIDTH-1:0]                     accumulate_short  [0:N-1];
  logic unsigned [M_LOG2-1:0]                         accumulate_counter;

  logic signed [M_LOG2+N_LOG2+G_DATA_WIDTH+G_TAP_WIDTH-1:0] accumulate_2;
  logic signed [M_LOG2+N_LOG2+G_DATA_WIDTH+G_TAP_WIDTH-1:0] accumulate_2_rs;
  logic signed [G_DATA_WIDTH-1:0]                           accumulate_2_short;

  logic mult_dout_valid;
  logic signed [G_DATA_WIDTH+G_TAP_WIDTH-1:0] mult [0:N-1];

//////////////////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      brm_din_rd_din_valid        <= 0;
      brm_din_rd_din_valid_gate   <= 0;
      tap_din_ready               <= 0;
      tap_din_done                <= 0;
      din_ready                   <= 0;
      dout_valid                  <= 0;
      state                       <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin

          for (int i = 0 ; i < N-1 ; i++) begin
            registered_bram_data[i] <= 0;
          end

          brm_din_rd_din_valid_gate   <= 1;
          program_counter <= 0;
          tap_din_ready   <= 1;
          brm_din_wr_din_addr <= 0;
          brm_din_rd_din_addr <= 0;

          //for (int i = 0 ; i < N ; i++) begin
          //  brm_din_wr_din_value[i] <= 0;
          //end

          state           <= SM_PROGRAM_TAPS;
        end

        SM_PROGRAM_TAPS : begin
          if (tap_din_valid == 1 && tap_din_ready == 1) begin
            if (program_counter == M*N-1) begin
              din_ready                 <= 1;
              tap_din_ready             <= 0;
              brm_din_rd_din_valid_gate <= 0;
              brm_din_wr_din_addr       <= 0;
              tap_din_done              <= 1;
              state                     <= SM_GET_INPUT;
            end
            else begin
              program_counter <= program_counter + 1;
              brm_din_wr_din_addr <= brm_din_wr_din_addr + 1;
            end
          end
        end

        SM_GET_INPUT : begin
          if (din_valid == 1 && din_ready == 1) begin
            din_ready <= 0;
            brm_din_wr_din_addr <= M+1-1;
            brm_din_rd_din_addr <= M-1;
            brm_din_rd_din_valid  <= 1;
            accumulate_counter    <= 0;
            brm_taps_rd_din_addr <= 0;
            for (int i = 0 ; i < N ; i++) begin
              accumulate[i] <= 0;
            end
            state     <= SM_CALC;
          end
        end

        SM_CALC : begin

          if (brm_din_rd_din_valid == 1) begin
            if (brm_din_rd_din_addr == 0) begin
              brm_din_rd_din_valid <= 0;
            end
            else begin
              brm_din_rd_din_addr <= brm_din_rd_din_addr - 1;
            end
          end

          if (brm_din_rd_dout_valid[0] == 1 && brm_din_wr_din_valid == 0) begin
            for (int i = 0 ; i < N-1 ; i++) begin
              registered_bram_data[i] <= brm_din_rd_dout_value[i];
            end
          end

          if (brm_din_rd_dout_valid[0] == 1) begin
            brm_din_wr_din_addr <= brm_din_wr_din_addr - 1;
          end


          if (mult_dout_valid == 1) begin
            if (accumulate_counter == M-1) begin
              accumulate_counter  <= 0;
              accumulate_2        <= 0;
              state               <= SM_ADD2;
            end
            else begin
              accumulate_counter <= accumulate_counter + 1;
            end
            for (int i = 0 ; i < N ; i++) begin
              accumulate[i] <= accumulate[i] + mult[i];
            end
          end

        end

        //SM_RESIZE : begin
        //  for (int i = 0 ; i < N ; i++) begin
        //    accumulate_rs[i] = accumulate[i] >>> G_TAP_WIDTH;
        //    if (accumulate_rs[i] > (2**G_DATA_WIDTH)-1) begin
        //      accumulate_short[i] <= (2**G_DATA_WIDTH)-1;
        //    end
        //    else if (accumulate_rs[i] < -(2**G_DATA_WIDTH)) begin
        //      accumulate_short[i] <= -2**G_DATA_WIDTH;
        //    end
        //    else begin
        //      accumulate_short[i] <= accumulate_rs[i];
        //    end
        //  end
        //  accumulate_counter  <= 0;
        //  accumulate_2        <= 0;
        //  state               <= SM_ADD2;
        //end

        SM_ADD2 : begin
          if (accumulate_counter == N-1) begin
            state               <= SM_RESIZE2;
          end
          else begin
            accumulate_counter  <= accumulate_counter + 1;
          end
          accumulate_2          <= accumulate_2 + accumulate[accumulate_counter];
        end

        SM_RESIZE2 : begin
          accumulate_2_rs = accumulate_2 >>> (G_TAP_WIDTH-1);
          if (accumulate_2_rs > (2**G_DATA_WIDTH)-1) begin
            accumulate_2_short <= 2**G_DATA_WIDTH-1;
          end
          else if (accumulate_2_rs < -(2**G_DATA_WIDTH)) begin
            accumulate_2_short <= -2**G_DATA_WIDTH;
          end
          else begin
            accumulate_2_short <= accumulate_2_rs;
          end

          state       <= SM_OUTPUT;
        end

        SM_OUTPUT : begin

          if (dout_valid == 1 && dout_ready == 1) begin
            din_ready   <= 1;
            dout_valid  <= 0;
            state       <= SM_GET_INPUT;
          end
          else begin
            if (G_OUTPUT_UNSCALED == 1) begin
              dout      <= accumulate_2;
            end
            else begin
              dout      <= accumulate_2_short;
            end
            dout_valid  <= 1;
          end
        end

        default : begin
        end

      endcase
    end
  end

  assign brm_taps_wr_din_bank_counter = program_counter[N_LOG2+M_LOG2-1 -: N_LOG2];
  assign brm_taps_wr_din_addr = program_counter[M_LOG2-1 -: M_LOG2];


  assign brm_taps_wr_din_value = tap_din;

  always_comb begin

    case (state)

      SM_PROGRAM_TAPS : begin
        brm_din_wr_din_valid = 1;
        for (int i = 0 ; i < N ; i++) begin
          brm_din_wr_din_value[i] = 0;
        end
      end

      SM_GET_INPUT : begin
        brm_din_wr_din_valid        = din_valid;
        for (int i = 0 ; i < N ; i++) begin
          if (i == 0) begin
            brm_din_wr_din_value[i] = din;
          end
          else begin
            brm_din_wr_din_value[i] = registered_bram_data[i-1];
          end
        end
      end

      SM_CALC : begin
        if (brm_din_wr_din_addr == 0) begin
          brm_din_wr_din_valid      = 0;
        end
        else begin
          brm_din_wr_din_valid      = brm_din_rd_dout_valid[0];
        end

        for (int i = 0 ; i < N ; i++) begin
          brm_din_wr_din_value[i]   = brm_din_rd_dout_value[i];
        end

      end

      default : begin
        brm_din_wr_din_valid = 0;
        for (int i = 0 ; i < N ; i++) begin
          brm_din_wr_din_value[i]   = 0;
        end
      end

    endcase
  end

  generate
    for (genvar i = 0 ; i < N ; i++) begin

      assign brm_taps_wr_din_valid[i] = (brm_taps_wr_din_bank_counter == i) ? tap_din_valid : 0;



      config_fir_bram
      #(
        .G_ADDR_WIDTH   (M_LOG2),
        .G_DATA_WIDTH   (G_DATA_WIDTH)
      )
      u_din_bram
      (
        .clk            (clk),

        .wr_din_addr    (brm_din_wr_din_addr      ),
        .wr_din_value   (brm_din_wr_din_value[i]  ),
        .wr_din_valid   (brm_din_wr_din_valid     ),

        .rd_din_addr    (brm_din_rd_din_addr      ),
        .rd_din_valid   (brm_din_rd_din_valid     ),

        .rd_dout_value  (brm_din_rd_dout_value[i] ),
        .rd_dout_valid  (brm_din_rd_dout_valid[i] )
      );

      config_fir_bram
      #(
        .G_ADDR_WIDTH   (M_LOG2),
        .G_DATA_WIDTH   (G_TAP_WIDTH)
      )
      u_taps_bram
      (
        .clk            (clk),

        .wr_din_addr    (brm_taps_wr_din_addr       ),
        .wr_din_value   (brm_taps_wr_din_value      ),
        .wr_din_valid   (brm_taps_wr_din_valid[i]   ),

        .rd_din_addr    (brm_din_rd_din_addr        ),
        .rd_din_valid   (brm_din_rd_din_valid       ),

        .rd_dout_value  (brm_taps_rd_dout_value[i]  ),
        .rd_dout_valid  (brm_taps_rd_dout_valid[i]  )
      );

    end
  endgenerate

  always @ (posedge clk) begin
    for (int i = 0 ; i < N ; i++) begin
      mult[i]   <= signed'(brm_din_rd_dout_value[i])*signed'(brm_taps_rd_dout_value[i]);
    end
    mult_dout_valid  <= brm_din_rd_dout_valid[0];
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


