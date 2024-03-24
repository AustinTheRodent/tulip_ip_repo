
module interpolating_lut
#(
  parameter int               G_ADDR_WIDTH = 10,
  parameter int               G_DWIDTH = 24,
  parameter int               G_LOG2_LINEAR_STEPS = 8 // 2**8 steps = 256 steps
)
(
  input  logic                clk,
  input  logic                reset,
  input  logic                enable,

  input  logic [G_DWIDTH-1:0] lut_prog_din,
  input  logic                lut_prog_din_valid,
  output logic                lut_prog_din_ready,
  output logic                lut_prog_din_done,

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
    SM_PROGRAM_LUT,
    SM_GET_INPUT,
    SM_GET_FLOOR,
    SM_GET_CEIL,
    SM_INTERPOLATE,
    SM_SEND_OUTPUT
  } state_t;

  state_t state;

  logic unsigned [G_ADDR_WIDTH-1:0] prog_lut_counter;
  logic [G_DWIDTH-1:0]              din_store;

  logic [G_ADDR_WIDTH-1:0]          bram_din_addr;
  logic                             bram_din_valid;
  logic [G_DWIDTH-1:0]              bram_dout_value;
  logic                             bram_dout_valid;

  logic unsigned [G_DWIDTH-1:0]     floor_store;
  logic unsigned [G_DWIDTH-1:0]     ceil_store;

  logic signed [G_DWIDTH-1:0]       delta;
  logic signed [G_DWIDTH-1:0]       delta_floor;

  logic unsigned [G_LOG2_LINEAR_STEPS-1:0]  sub_index;
  logic signed [G_DWIDTH-1:0]               dout_store;

/////////////////////////////////////////////////////

  assign dout = dout_store;

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
      lut_prog_din_ready  <= 0;
      lut_prog_din_done   <= 0;
      din_ready           <= 0;
      dout_valid          <= 0;
      bram_din_valid      <= 0;
      state               <= SM_INIT;
    end
    else begin
      case (state)

        SM_INIT : begin
          lut_prog_din_ready  <= 1;
          prog_lut_counter    <= 0;
          state               <= SM_PROGRAM_LUT;
        end

        SM_PROGRAM_LUT : begin
          if (lut_prog_din_valid == 1 && lut_prog_din_ready ==1) begin
            if (prog_lut_counter == 2**G_ADDR_WIDTH-1) begin
              lut_prog_din_ready  <= 0;
              lut_prog_din_done   <= 1;
              din_ready           <= 1;
              state               <= SM_GET_INPUT;
            end
            else begin
              prog_lut_counter    <= prog_lut_counter + 1;
            end
          end
        end

        SM_GET_INPUT : begin
          if (din_valid == 1 && din_ready == 1) begin
            din_ready       <= 0;
            din_store       <= din;
            bram_din_addr   <= din[G_DWIDTH-1 -: G_ADDR_WIDTH];
            sub_index       <= din[G_DWIDTH-G_ADDR_WIDTH-1 -: G_LOG2_LINEAR_STEPS];
            bram_din_valid  <= 1;
            state           <= SM_GET_FLOOR;
          end
        end

        SM_GET_FLOOR : begin

          bram_din_valid      <= 0;
          if (bram_dout_valid == 1) begin
            floor_store       <= bram_dout_value;
            if (bram_din_addr < 2**G_ADDR_WIDTH-1) begin
              bram_din_addr   <= bram_din_addr + 1;
              bram_din_valid  <= 1;
              state           <= SM_GET_CEIL;
            end
            else begin
              ceil_store      <= bram_dout_value;
              state           <= SM_INTERPOLATE;
            end
          end

        end

        SM_GET_CEIL : begin
          bram_din_valid  <= 0;
          if (bram_dout_valid == 1) begin
            ceil_store    <= bram_dout_value;
            delta         = (signed'({1'b0,bram_dout_value}) - signed'({1'b0,floor_store})) >>> G_LOG2_LINEAR_STEPS;
            if (delta < 0) begin
              delta_floor <= delta + 1;
            end
            else begin
              delta_floor <= delta;
            end
            state         <= SM_INTERPOLATE;
          end
        end

        SM_INTERPOLATE : begin
          if (floor_store == ceil_store) begin
            dout_store  <= floor_store;
          end
          else begin
            dout_store  <= floor_store + delta_floor*signed'({1'b0,sub_index});
          end
          dout_valid    <= 1;
          state         <= SM_SEND_OUTPUT;
        end

        SM_SEND_OUTPUT : begin
          if (dout_valid == 1 && dout_ready == 1) begin
            din_ready   <= 1;
            dout_valid  <= 0;
            state       <= SM_GET_INPUT;
          end
        end

        default : begin
        end

      endcase
    end
  end

  interpolating_lut_bram
  #(
    .G_ADDR_WIDTH   (G_ADDR_WIDTH),
    .G_DATA_WIDTH   (G_DWIDTH)
  )
  u_bram
  (
    .clk            (clk),

    .wr_din_addr    (prog_lut_counter),
    .wr_din_value   (lut_prog_din),
    .wr_din_valid   (lut_prog_din_valid & lut_prog_din_ready),

    .rd_din_addr    (bram_din_addr),
    .rd_din_valid   (bram_din_valid),

    .rd_dout_value  (bram_dout_value),
    .rd_dout_valid  (bram_dout_valid)
  );

endmodule

module interpolating_lut_bram
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
