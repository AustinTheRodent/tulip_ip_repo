module fir_taps_4x_brom
(
  input  logic        clk,

  input  logic [5:0]  din_address,
  input  logic        din_valid,

  output logic [15:0] dout,
  output logic        dout_valid
);

  logic signed [15:0] brom_data [0:2**6-1] =
  {
    27           ,
    -5           ,
    -24          ,
    -46          ,
    -57          ,
    -45          ,
    -4           ,
    59           ,
    118          ,
    143          ,
    106          ,
    5            ,
    -136         ,
    -261         ,
    -305         ,
    -220         ,
    -6           ,
    278          ,
    524          ,
    605          ,
    434          ,
    7            ,
    -566         ,
    -1078        ,
    -1278        ,
    -953         ,
    -8           ,
    1475         ,
    3241         ,
    4921         ,
    6125         ,
    6562         ,
    6125         ,
    4921         ,
    3241         ,
    1475         ,
    -8           ,
    -953         ,
    -1278        ,
    -1078        ,
    -566         ,
    7            ,
    434          ,
    605          ,
    524          ,
    278          ,
    -6           ,
    -220         ,
    -305         ,
    -261         ,
    -136         ,
    5            ,
    106          ,
    143          ,
    118          ,
    59           ,
    -4           ,
    -45          ,
    -57          ,
    -46          ,
    -24          ,
    -5           ,
    27           ,
    0
  };

/////////////////////////////////////////////////////////////////////

  always @ (posedge clk) begin
    dout        <= brom_data[din_address];
    dout_valid  <= din_valid;
  end

endmodule
