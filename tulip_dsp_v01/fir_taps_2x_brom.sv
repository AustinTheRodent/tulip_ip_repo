module fir_taps_2x_brom
(
  input  logic        clk,

  input  logic [4:0]  din_address,
  input  logic        din_valid,

  output logic [15:0] dout,
  output logic        dout_valid
);

  logic signed [15:0] brom_data [0:2**5-1] =
  {
    7             ,
    -89           ,
    -79           ,
    116           ,
    271           ,
    0             ,
    -511          ,
    -423          ,
    559           ,
    1194          ,
    1             ,
    -2151         ,
    -1888         ,
    2959          ,
    9834          ,
    13108         ,
    9834          ,
    2959          ,
    -1888         ,
    -2151         ,
    1             ,
    1194          ,
    559           ,
    -423          ,
    -511          ,
    0             ,
    271           ,
    116           ,
    -79           ,
    -89           ,
    7             ,
    0
  };

/////////////////////////////////////////////////////////////////////

  always @ (posedge clk) begin
    dout        <= brom_data[din_address];
    dout_valid  <= din_valid;
  end

endmodule
