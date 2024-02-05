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
