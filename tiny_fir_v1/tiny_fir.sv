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
    SM_GET_INPUT,
    SM_CALC_MULT,
    SM_ACCUMULATE,
    SM_SEND_OUTPUT
  } state_t;

//////////////////////////////////////////////////////

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin
    end
    else begin
    end
  end
  
  tiny_fir_bram
  #(
    .G_ADDR_WIDTH  ($clog2(G_NUM_TAPS)),
    .G_DATA_WIDTH  (G_TAP_WIDTH)
  )
  u_taps_bram
  (
    .clk            (clk),
  
    .wr_din_addr    (),
    .wr_din_value   (),
    .wr_din_valid   (),
  
    .rd_din_addr    (),
    .rd_din_valid   (),
  
    .rd_dout_value  (),
    .rd_dout_valid  ()
  );


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


