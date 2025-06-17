library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.button_iface_pkg.all;

entity tulip_button_interface is
  generic
  (
    G_SPI_MSB_FIRST   : natural range 0 to 1  := 1 -- 0=LSB_FIRST
  );
  port
  (
    rot_enc_a         : in  std_logic;
    rot_enc_b         : in  std_logic;
    --rot_enc_push      : in  std_logic;
    buttons           : in  std_logic_vector(4 downto 0);
    interrupt         : out std_logic;

    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------

    s_axil_aclk       : in  std_logic;
    s_axil_aresetn    : in  std_logic;

    s_axil_awaddr     : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axil_awvalid    : in  std_logic;
    s_axil_awready    : out std_logic;

    s_axil_wdata      : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axil_wstrb      : in  std_logic_vector(C_REG_FILE_DATA_WIDTH/8-1 downto 0);
    s_axil_wvalid     : in  std_logic;
    s_axil_wready     : out std_logic;

    s_axil_bresp      : out std_logic_vector(1 downto 0);
    s_axil_bvalid     : out std_logic;
    s_axil_bready     : in  std_logic;

    s_axil_araddr     : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axil_arvalid    : in  std_logic;
    s_axil_arready    : out std_logic;

    s_axil_rdata      : out std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axil_rresp      : out std_logic_vector(1 downto 0);
    s_axil_rvalid     : out std_logic;
    s_axil_rready     : in  std_logic


  );
end entity;

architecture rtl of tulip_button_interface is

  signal registers : reg_t;

  type rotary_encoder_state_t is
  (
    SM_E_INIT,
    SM_E_A_LOW_B_HIGH,
    SM_E_A_LOW_B_HIGH_B,
    SM_E_B_LOW_A_HIGH,
    SM_E_B_LOW_A_HIGH_A,
    SM_E_AB_HIGH,
    SM_E_AB_LOW_B,
    SM_E_AB_LOW_A
  );

  signal rot_enc_a_meta : std_logic;
  signal rot_enc_b_meta : std_logic;
  signal rot_enc_a_s    : std_logic;
  signal rot_enc_b_s    : std_logic;

  signal rotary_encoder_state : rotary_encoder_state_t;

  signal rotary_a_pulse           : std_logic;
  signal rotary_b_pulse           : std_logic;

  signal buttons_debounced        : std_logic_vector(buttons'range);
  signal buttons_debounced_store  : std_logic_vector(buttons'range);
  signal buttons_debounced_re     : std_logic_vector(buttons'range);
  signal buttons_debounced_fe     : std_logic_vector(buttons'range);


  --signal a_turn : std_logic;
  --signal b_turn : std_logic;

begin

  interrupt <= '0' when unsigned(registers.BUTTON_INTERRUPT_REG) = 0 else '1';

  u_reg_file : entity work.button_iface
  port map
  (
    s_axi_aclk    => s_axil_aclk,
    s_axi_aresetn => s_axil_aresetn,

    s_BUTTONS_STATUS_BUTTON4        => buttons_debounced(4),
    s_BUTTONS_STATUS_BUTTON4_v      => '1',

    s_BUTTONS_STATUS_BUTTON3        => buttons_debounced(3),
    s_BUTTONS_STATUS_BUTTON3_v      => '1',

    s_BUTTONS_STATUS_BUTTON2        => buttons_debounced(2),
    s_BUTTONS_STATUS_BUTTON2_v      => '1',

    s_BUTTONS_STATUS_BUTTON1        => buttons_debounced(1),
    s_BUTTONS_STATUS_BUTTON1_v      => '1',

    s_BUTTONS_STATUS_BUTTON0        => buttons_debounced(0),
    s_BUTTONS_STATUS_BUTTON0_v      => '1',

    s_BUTTONS_STATUS_ROTARY_B       => rot_enc_b,
    s_BUTTONS_STATUS_ROTARY_B_v     => '1',

    s_BUTTONS_STATUS_ROTARY_A       => rot_enc_a,
    s_BUTTONS_STATUS_ROTARY_A_v     => '1',

    s_BUTTON_INTERRUPT_BUTTON4_FE   => buttons_debounced_fe(4),
    s_BUTTON_INTERRUPT_BUTTON4_FE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON4_FE,

    s_BUTTON_INTERRUPT_BUTTON3_FE   => buttons_debounced_fe(3),
    s_BUTTON_INTERRUPT_BUTTON3_FE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON3_FE,

    s_BUTTON_INTERRUPT_BUTTON2_FE   => buttons_debounced_fe(2),
    s_BUTTON_INTERRUPT_BUTTON2_FE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON2_FE,

    s_BUTTON_INTERRUPT_BUTTON1_FE   => buttons_debounced_fe(1),
    s_BUTTON_INTERRUPT_BUTTON1_FE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON1_FE,

    s_BUTTON_INTERRUPT_BUTTON0_FE   => buttons_debounced_fe(0),
    s_BUTTON_INTERRUPT_BUTTON0_FE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON0_FE,

    s_BUTTON_INTERRUPT_BUTTON4_RE   => buttons_debounced_re(4),
    s_BUTTON_INTERRUPT_BUTTON4_RE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON4_RE,

    s_BUTTON_INTERRUPT_BUTTON3_RE   => buttons_debounced_re(3),
    s_BUTTON_INTERRUPT_BUTTON3_RE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON3_RE,

    s_BUTTON_INTERRUPT_BUTTON2_RE   => buttons_debounced_re(2),
    s_BUTTON_INTERRUPT_BUTTON2_RE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON2_RE,

    s_BUTTON_INTERRUPT_BUTTON1_RE   => buttons_debounced_re(1),
    s_BUTTON_INTERRUPT_BUTTON1_RE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON1_RE,

    s_BUTTON_INTERRUPT_BUTTON0_RE   => buttons_debounced_re(0),
    s_BUTTON_INTERRUPT_BUTTON0_RE_v => registers.BUTTON_INTERRUPT_ENABLE.BUTTON0_RE,

    s_BUTTON_INTERRUPT_ROTARY_B     => rotary_b_pulse,
    s_BUTTON_INTERRUPT_ROTARY_B_v   => registers.BUTTON_INTERRUPT_ENABLE.ROTARY_B,

    s_BUTTON_INTERRUPT_ROTARY_A     => rotary_a_pulse,
    s_BUTTON_INTERRUPT_ROTARY_A_v   => registers.BUTTON_INTERRUPT_ENABLE.ROTARY_A,

    s_BUTTON_DEBUG_STATE    => (others => '0'),
    s_BUTTON_DEBUG_STATE_v  => '1',

    s_axi_awaddr  => s_axil_awaddr,
    s_axi_awvalid => s_axil_awvalid,
    s_axi_awready => s_axil_awready,

    s_axi_wdata   => s_axil_wdata,
    s_axi_wstrb   => s_axil_wstrb,
    s_axi_wvalid  => s_axil_wvalid,
    s_axi_wready  => s_axil_wready,

    s_axi_bresp   => s_axil_bresp,
    s_axi_bvalid  => s_axil_bvalid,
    s_axi_bready  => s_axil_bready,

    s_axi_araddr  => s_axil_araddr,
    s_axi_arvalid => s_axil_arvalid,
    s_axi_arready => s_axil_arready,

    s_axi_rdata   => s_axil_rdata,
    s_axi_rresp   => s_axil_rresp,
    s_axi_rvalid  => s_axil_rvalid,
    s_axi_rready  => s_axil_rready,

    registers_out => registers
  );

  p_stabalize_rotary_encoder : process(s_axil_aclk)
  begin
    if rising_edge(s_axil_aclk) then
      rot_enc_a_meta  <= rot_enc_a;
      rot_enc_b_meta  <= rot_enc_b;

      rot_enc_a_s <= rot_enc_a_meta;
      rot_enc_b_s <= rot_enc_b_meta;
    end if;
  end process;

  p_rotary_encoder_sm : process(s_axil_aclk)
  begin
    if rising_edge(s_axil_aclk) then
      if s_axil_aresetn = '0' or registers.BUTTON_CONTROL.SW_RESETN = '0' then
        rotary_encoder_state  <= SM_E_INIT;
        rotary_a_pulse        <= '0';
        rotary_b_pulse        <= '0';
      else
        case rotary_encoder_state is
          when SM_E_INIT =>
            rotary_encoder_state  <= SM_E_AB_HIGH;
            rotary_a_pulse        <= '0';
            rotary_b_pulse        <= '0';

          when SM_E_AB_HIGH =>
            if rot_enc_a_s = '0' and rot_enc_b_s = '1' then
              rotary_encoder_state  <= SM_E_A_LOW_B_HIGH;
            elsif rot_enc_b_s = '0' and rot_enc_a_s = '1' then
              rotary_encoder_state  <= SM_E_B_LOW_A_HIGH;
            end if;
            rotary_a_pulse          <= '0';
            rotary_b_pulse          <= '0';

          when SM_E_A_LOW_B_HIGH =>
            if rot_enc_a_s = '1' then
              rotary_encoder_state  <= SM_E_AB_HIGH;
            elsif rot_enc_b_s = '0' and rot_enc_a_s = '0' then
              rotary_encoder_state  <= SM_E_AB_LOW_A;
            end if;

            when SM_E_AB_LOW_A =>
              if rot_enc_a_s = '1' and rot_enc_b_s = '0' then
                rotary_encoder_state  <= SM_E_B_LOW_A_HIGH_A;
              elsif rot_enc_a_s = '0' and rot_enc_b_s = '1' then
                rotary_encoder_state <= SM_E_A_LOW_B_HIGH;
              elsif rot_enc_a_s = '1' and rot_enc_b_s = '1' then
                rotary_encoder_state <= SM_E_AB_HIGH;
              end if;

            when SM_E_B_LOW_A_HIGH_A =>
              if rot_enc_a_s = '1' and rot_enc_b_s = '1' then
                rotary_a_pulse          <= '1';
                rotary_b_pulse          <= '0';
                rotary_encoder_state <= SM_E_AB_HIGH;
              elsif rot_enc_a_s = '0' and rot_enc_b_s = '0' then
                rotary_encoder_state  <= SM_E_AB_LOW_A;
              elsif rot_enc_a_s = '0' and rot_enc_b_s = '1' then
                rotary_encoder_state <= SM_E_A_LOW_B_HIGH;
              end if;







          when SM_E_B_LOW_A_HIGH =>
            if rot_enc_b_s = '1' then
              rotary_encoder_state  <= SM_E_AB_HIGH;
            elsif rot_enc_a_s = '0' and rot_enc_b_s = '0' then
              rotary_encoder_state  <= SM_E_AB_LOW_B;
            end if;

            when SM_E_AB_LOW_B =>
              if rot_enc_a_s = '0' and rot_enc_b_s = '1' then
                rotary_encoder_state  <= SM_E_A_LOW_B_HIGH_B;
              elsif rot_enc_a_s = '1' and rot_enc_b_s = '0' then
                rotary_encoder_state <= SM_E_B_LOW_A_HIGH;
              elsif rot_enc_a_s = '1' and rot_enc_b_s = '1' then
                rotary_encoder_state <= SM_E_AB_HIGH;
              end if;

            when SM_E_A_LOW_B_HIGH_B =>
              if rot_enc_a_s = '1' and rot_enc_b_s = '1' then
                rotary_a_pulse          <= '0';
                rotary_b_pulse          <= '1';
                rotary_encoder_state    <= SM_E_AB_HIGH;
              elsif rot_enc_a_s = '0' and rot_enc_b_s = '0' then
                rotary_encoder_state  <= SM_E_AB_LOW_B;
              elsif rot_enc_a_s = '1' and rot_enc_b_s = '0' then
                rotary_encoder_state <= SM_E_B_LOW_A_HIGH;
              end if;

--          when SM_E_AB_LOW =>
--            rotary_a_pulse  <= '0';
--            rotary_b_pulse  <= '0';
--
--            if rot_enc_a_s = '1' and rot_enc_b_s = '1' then
--              rotary_encoder_state  <= SM_E_AB_HIGH;
--            end if;


          when others =>
            null;

        end case;
      end if;
    end if;
  end process;

  buttons_debounced_re  <= buttons_debounced and (not buttons_debounced_store);
  buttons_debounced_fe  <= buttons_debounced_store and (not buttons_debounced);

  p_button_pulse : process(s_axil_aclk)
  begin
    if rising_edge(s_axil_aclk) then
      buttons_debounced_store <= buttons_debounced;
    end if;
  end process;

  gen_button_debounce : for i in 0 to buttons'length-1 generate
    u_debounce_input : entity work.debounce_button
    port map
    (
      clk                     => s_axil_aclk,
      aresetn                 => s_axil_aresetn and registers.BUTTON_CONTROL.SW_RESETN,

      post_rising_edge_delay  => registers.BUTTON_POST_RISING_EDGE_DELAY.VALUE,
      post_falling_edge_delay => registers.BUTTON_POST_FALLING_EDGE_DELAY.VALUE,
      rising_edge_min_count   => registers.BUTTON_RISING_EDGE_MIN_COUNT.VALUE,
      falling_edge_min_count  => registers.BUTTON_FALLING_EDGE_MIN_COUNT.VALUE,

      din_bounce              => buttons(i),
      dout_debounced          => buttons_debounced(i)
    );
    end generate;


end rtl;
