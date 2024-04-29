module tiny_iir_floating_point
#(
  parameter int G_DEGREE = 3
)
(
  input  logic        clk,
  input  logic        reset,
  input  logic        enable,
  input  logic        bypass,

  input  logic [31:0] b_tap,
  input  logic        b_tap_valid,
  output logic        b_tap_ready,
  output logic        b_tap_done,

  input  logic [31:0] a_tap,
  input  logic        a_tap_valid,
  output logic        a_tap_ready,
  output logic        a_tap_done,

  input  logic [31:0] din,
  input  logic        din_valid,
  output logic        din_ready,

  output logic [31:0] dout,
  output logic        dout_valid,
  input  logic        dout_ready
);

  logic         din_ready_int;
  logic [31:0]  dout_int;
  logic         dout_valid_int;

  typedef logic [31:0] float_t;

  typedef enum
  {
    SM_INIT,
    SM_PROGRAM_TAPS,
    SM_GET_INPUT,
    SM_MULT_B_TAPS,
    SM_MULT_A_TAPS,
    SM_ACCUMULATE_B_TAPS,
    SM_ACCUMULATE_A_TAPS,
    SM_ACCUMULATE_AB_TAPS,
    SM_SEND_OUTPUT
  } state_t;
  state_t state;

  logic unsigned [$clog2(G_DEGREE)-1:0] a_taps_prog_counter;
  logic unsigned [$clog2(G_DEGREE)-1:0] b_taps_prog_counter;
  logic unsigned [$clog2(G_DEGREE)-1:0] mult_b_din_counter;
  logic unsigned [$clog2(G_DEGREE)-1:0] mult_b_dout_counter;
  logic unsigned [$clog2(G_DEGREE)-1:0] mult_a_din_counter;
  logic unsigned [$clog2(G_DEGREE)-1:0] mult_a_dout_counter;
  logic unsigned [$clog2(G_DEGREE)-1:0] accum_b_counter;
  logic unsigned [$clog2(G_DEGREE)-1:0] accum_a_counter;

  float_t a_taps      [0:G_DEGREE-1];
  float_t a_taps_neg  [0:G_DEGREE-1];
  float_t b_taps      [0:G_DEGREE-1];
  float_t x_nm        [0:G_DEGREE-1];
  float_t y_nm        [0:G_DEGREE-1];
  float_t a_mult      [0:G_DEGREE-1];
  //float_t a_mult      [0:G_DEGREE-1];
  float_t b_mult      [0:G_DEGREE-1];

  float_t b_accumulate;
  float_t a_accumulate;
  float_t ab_accumulate;

  float_t fp_mult_din1;
  float_t fp_mult_din2;
  logic   fp_mult_din_valid;
  float_t fp_mult_dout;
  logic   fp_mult_dout_valid;

  float_t fp_add_din1;
  float_t fp_add_din2;
  logic   fp_add_din_valid;
  float_t fp_add_dout;
  logic   fp_add_dout_valid;

////////////////////////////////////////////

  always_comb begin
    if (bypass == 1) begin
      din_ready   = dout_ready;
      dout        = din;
      dout_valid  = din_valid;
    end
    else begin
      din_ready   = din_ready_int;
      dout        = dout_int;
      dout_valid  = dout_valid_int;
    end
  end

  generate
    for (genvar i = 0 ; i < G_DEGREE ; i++) begin
      assign a_taps_neg[i] = {~a_taps[i][31] , a_taps[i][30 -: 31]};
    end
  endgenerate

  always @ (posedge clk) begin
    if (reset == 1 || enable == 0) begin

      for (int i = 0 ; i < G_DEGREE ; i++) begin
        x_nm[i] <= 0;
        y_nm[i] <= 0;
      end
      b_tap_done        <= 0;
      a_tap_done        <= 0;
      din_ready_int         <= 0;
      dout_valid_int        <= 0;
      a_tap_ready       <= 0;
      b_tap_ready       <= 0;
      fp_mult_din_valid <= 0;
      fp_add_din_valid  <= 0;
      state             <= SM_INIT;
    end
    else begin
      case (state)
        SM_INIT : begin
          a_tap_ready         <= 1;
          b_tap_ready         <= 1;
          b_taps_prog_counter <= 0;
          a_taps_prog_counter <= 0;
          state               <= SM_PROGRAM_TAPS;
        end

        SM_PROGRAM_TAPS : begin
          if (a_tap_done == 1 && b_tap_done == 1) begin
            din_ready_int <= 1;
            state     <= SM_GET_INPUT;
          end

          if (a_tap_valid == 1 && a_tap_ready == 1) begin
            a_taps[a_taps_prog_counter] <= a_tap;
            if (a_taps_prog_counter == G_DEGREE-1) begin
              a_tap_ready <= 0;
              a_tap_done  <= 1;
            end
            else begin
              a_taps_prog_counter <= a_taps_prog_counter + 1;
            end
          end

          if (b_tap_valid == 1 && b_tap_ready == 1) begin
            b_taps[b_taps_prog_counter] <= b_tap;
            if (b_taps_prog_counter == G_DEGREE-1) begin
              b_tap_ready <= 0;
              b_tap_done  <= 1;
            end
            else begin
              b_taps_prog_counter <= b_taps_prog_counter + 1;
            end
          end

        end

        SM_GET_INPUT : begin
          if (din_valid == 1 && din_ready_int == 1) begin
            x_nm[0]     <= din;
            for (int i = 0 ; i < G_DEGREE-1 ; i++) begin
              x_nm[i+1] <= x_nm[i];
            end
            din_ready_int           <= 0;
            fp_mult_din1        <= b_taps[0];
            fp_mult_din2        <= din;
            fp_mult_din_valid   <= 1;
            mult_b_din_counter  <= 0;
            mult_b_dout_counter <= 0;
            state               <= SM_MULT_B_TAPS;
          end
        end

        SM_MULT_B_TAPS : begin

          if (mult_b_din_counter == G_DEGREE-1) begin
            fp_mult_din_valid <= 0;
          end
          else begin
            fp_mult_din1        <= b_taps[mult_b_din_counter+1];
            fp_mult_din2        <= x_nm[mult_b_din_counter+1];
            mult_b_din_counter  <= mult_b_din_counter + 1;
          end

          if (fp_mult_dout_valid == 1) begin
            b_mult[mult_b_dout_counter] <= fp_mult_dout;
            if (mult_b_dout_counter == G_DEGREE-1) begin
              fp_mult_din1        <= a_taps_neg[1];
              fp_mult_din2        <= y_nm[1];
              fp_mult_din_valid   <= 1;
              mult_a_din_counter  <= 1;
              mult_a_dout_counter <= 1;
              state               <= SM_MULT_A_TAPS;
            end
            else begin
              mult_b_dout_counter <= mult_b_dout_counter + 1;
            end
          end

        end

        SM_MULT_A_TAPS : begin

          if (mult_a_din_counter == G_DEGREE-1) begin
            fp_mult_din_valid <= 0;
          end
          else begin
            fp_mult_din1        <= a_taps_neg[mult_a_din_counter+1];
            fp_mult_din2        <= y_nm[mult_a_din_counter+1];
            mult_a_din_counter  <= mult_a_din_counter + 1;
          end

          if (fp_mult_dout_valid == 1) begin
            a_mult[mult_a_dout_counter] <= fp_mult_dout;
            if (mult_a_dout_counter == G_DEGREE-1) begin
              accum_b_counter     <= 2;
              fp_add_din1         <= b_mult[0];
              fp_add_din2         <= b_mult[1];
              fp_add_din_valid    <= 1;
              state               <= SM_ACCUMULATE_B_TAPS;
            end
            else begin
              mult_a_dout_counter <= mult_a_dout_counter + 1;
            end
          end

        end

        SM_ACCUMULATE_B_TAPS : begin
          if (fp_add_dout_valid == 1) begin
            if (accum_b_counter == G_DEGREE) begin
              accum_a_counter     <= 3;
              fp_add_din1         <= a_mult[1];
              fp_add_din2         <= a_mult[2];
              fp_add_din_valid    <= 1;
              b_accumulate      <= fp_add_dout;
              state             <= SM_ACCUMULATE_A_TAPS;
            end
            else begin
              fp_add_din1       <= fp_add_dout;
              fp_add_din2       <= b_mult[accum_b_counter];
              fp_add_din_valid  <= 1;
              accum_b_counter   <= accum_b_counter + 1;
            end
          end
          else begin
            fp_add_din_valid <= 0;
          end
        end

        SM_ACCUMULATE_A_TAPS : begin
          if (fp_add_dout_valid == 1) begin
            if (accum_a_counter == G_DEGREE) begin
              fp_add_din1         <= fp_add_dout;
              fp_add_din2         <= b_accumulate;
              fp_add_din_valid    <= 1;
              a_accumulate      <= fp_add_dout;
              state             <= SM_ACCUMULATE_AB_TAPS;
            end
            else begin
              fp_add_din1       <= fp_add_dout;
              fp_add_din2       <= a_mult[accum_a_counter];
              fp_add_din_valid  <= 1;
              accum_a_counter   <= accum_a_counter + 1;
            end
          end
          else begin
            fp_add_din_valid <= 0;
          end
        end

        SM_ACCUMULATE_AB_TAPS : begin
          fp_add_din_valid <= 0;
          if (fp_add_dout_valid == 1) begin
            ab_accumulate <= fp_add_dout;
            dout_int          <= fp_add_dout;
            dout_valid_int    <= 1;
            state         <= SM_SEND_OUTPUT;
          end
        end

        SM_SEND_OUTPUT : begin
          y_nm[1] <= ab_accumulate;
          if (dout_valid_int == 1 && dout_ready == 1) begin
            for (int i = 1 ; i < G_DEGREE-1 ; i++) begin
              y_nm[i+1] <= y_nm[i];
            end
            din_ready_int   <= 1;
            dout_valid_int  <= 0;
            state       <= SM_GET_INPUT;
          end
        end

        default : begin
        end

      endcase
    end
  end

  floating_point_mult_valid_only
  u_floating_point_mult_valid_only
  (
    .clk        (clk),

    .din1       (fp_mult_din1),
    .din2       (fp_mult_din2),
    .din_valid  (fp_mult_din_valid),

    .dout       (fp_mult_dout),
    .dout_valid (fp_mult_dout_valid)
  );

  floating_point_add_valid_only
  u_floating_point_add_valid_only
  (
    .clk        (clk),

    .din1       (fp_add_din1),
    .din2       (fp_add_din2),
    .din_valid  (fp_add_din_valid),

    .dout       (fp_add_dout),
    .dout_valid (fp_add_dout_valid)
  );

endmodule
