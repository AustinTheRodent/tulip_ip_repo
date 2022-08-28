 -- Quartus Prime VHDL Template
-- Single-Port ROM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sine_rom is

	generic 
	(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 8
	);

	port 
	(
		clk		: in std_logic;
		addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end entity;

architecture rtl of sine_rom is

	-- Build a 2-D array type for the ROM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	function init_rom
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
		--for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop 
			-- Initialize each address with the address itself
			--tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, DATA_WIDTH));
        tmp(0) := std_logic_vector(to_unsigned(32768, 16));
        tmp(1) := std_logic_vector(to_unsigned(33797, 16));
        tmp(2) := std_logic_vector(to_unsigned(34825, 16));
        tmp(3) := std_logic_vector(to_unsigned(35851, 16));
        tmp(4) := std_logic_vector(to_unsigned(36874, 16));
        tmp(5) := std_logic_vector(to_unsigned(37893, 16));
        tmp(6) := std_logic_vector(to_unsigned(38907, 16));
        tmp(7) := std_logic_vector(to_unsigned(39915, 16));
        tmp(8) := std_logic_vector(to_unsigned(40916, 16));
        tmp(9) := std_logic_vector(to_unsigned(41909, 16));
        tmp(10) := std_logic_vector(to_unsigned(42893, 16));
        tmp(11) := std_logic_vector(to_unsigned(43867, 16));
        tmp(12) := std_logic_vector(to_unsigned(44830, 16));
        tmp(13) := std_logic_vector(to_unsigned(45781, 16));
        tmp(14) := std_logic_vector(to_unsigned(46719, 16));
        tmp(15) := std_logic_vector(to_unsigned(47643, 16));
        tmp(16) := std_logic_vector(to_unsigned(48553, 16));
        tmp(17) := std_logic_vector(to_unsigned(49447, 16));
        tmp(18) := std_logic_vector(to_unsigned(50325, 16));
        tmp(19) := std_logic_vector(to_unsigned(51185, 16));
        tmp(20) := std_logic_vector(to_unsigned(52027, 16));
        tmp(21) := std_logic_vector(to_unsigned(52851, 16));
        tmp(22) := std_logic_vector(to_unsigned(53654, 16));
        tmp(23) := std_logic_vector(to_unsigned(54437, 16));
        tmp(24) := std_logic_vector(to_unsigned(55198, 16));
        tmp(25) := std_logic_vector(to_unsigned(55937, 16));
        tmp(26) := std_logic_vector(to_unsigned(56654, 16));
        tmp(27) := std_logic_vector(to_unsigned(57346, 16));
        tmp(28) := std_logic_vector(to_unsigned(58015, 16));
        tmp(29) := std_logic_vector(to_unsigned(58659, 16));
        tmp(30) := std_logic_vector(to_unsigned(59277, 16));
        tmp(31) := std_logic_vector(to_unsigned(59868, 16));
        tmp(32) := std_logic_vector(to_unsigned(60434, 16));
        tmp(33) := std_logic_vector(to_unsigned(60971, 16));
        tmp(34) := std_logic_vector(to_unsigned(61481, 16));
        tmp(35) := std_logic_vector(to_unsigned(61963, 16));
        tmp(36) := std_logic_vector(to_unsigned(62416, 16));
        tmp(37) := std_logic_vector(to_unsigned(62840, 16));
        tmp(38) := std_logic_vector(to_unsigned(63233, 16));
        tmp(39) := std_logic_vector(to_unsigned(63597, 16));
        tmp(40) := std_logic_vector(to_unsigned(63931, 16));
        tmp(41) := std_logic_vector(to_unsigned(64233, 16));
        tmp(42) := std_logic_vector(to_unsigned(64505, 16));
        tmp(43) := std_logic_vector(to_unsigned(64745, 16));
        tmp(44) := std_logic_vector(to_unsigned(64954, 16));
        tmp(45) := std_logic_vector(to_unsigned(65131, 16));
        tmp(46) := std_logic_vector(to_unsigned(65276, 16));
        tmp(47) := std_logic_vector(to_unsigned(65389, 16));
        tmp(48) := std_logic_vector(to_unsigned(65470, 16));
        tmp(49) := std_logic_vector(to_unsigned(65518, 16));
        tmp(50) := std_logic_vector(to_unsigned(65535, 16));
        tmp(51) := std_logic_vector(to_unsigned(65518, 16));
        tmp(52) := std_logic_vector(to_unsigned(65470, 16));
        tmp(53) := std_logic_vector(to_unsigned(65389, 16));
        tmp(54) := std_logic_vector(to_unsigned(65276, 16));
        tmp(55) := std_logic_vector(to_unsigned(65131, 16));
        tmp(56) := std_logic_vector(to_unsigned(64954, 16));
        tmp(57) := std_logic_vector(to_unsigned(64745, 16));
        tmp(58) := std_logic_vector(to_unsigned(64505, 16));
        tmp(59) := std_logic_vector(to_unsigned(64233, 16));
        tmp(60) := std_logic_vector(to_unsigned(63931, 16));
        tmp(61) := std_logic_vector(to_unsigned(63597, 16));
        tmp(62) := std_logic_vector(to_unsigned(63233, 16));
        tmp(63) := std_logic_vector(to_unsigned(62840, 16));
        tmp(64) := std_logic_vector(to_unsigned(62416, 16));
        tmp(65) := std_logic_vector(to_unsigned(61963, 16));
        tmp(66) := std_logic_vector(to_unsigned(61481, 16));
        tmp(67) := std_logic_vector(to_unsigned(60971, 16));
        tmp(68) := std_logic_vector(to_unsigned(60434, 16));
        tmp(69) := std_logic_vector(to_unsigned(59868, 16));
        tmp(70) := std_logic_vector(to_unsigned(59277, 16));
        tmp(71) := std_logic_vector(to_unsigned(58659, 16));
        tmp(72) := std_logic_vector(to_unsigned(58015, 16));
        tmp(73) := std_logic_vector(to_unsigned(57346, 16));
        tmp(74) := std_logic_vector(to_unsigned(56654, 16));
        tmp(75) := std_logic_vector(to_unsigned(55937, 16));
        tmp(76) := std_logic_vector(to_unsigned(55198, 16));
        tmp(77) := std_logic_vector(to_unsigned(54437, 16));
        tmp(78) := std_logic_vector(to_unsigned(53654, 16));
        tmp(79) := std_logic_vector(to_unsigned(52851, 16));
        tmp(80) := std_logic_vector(to_unsigned(52027, 16));
        tmp(81) := std_logic_vector(to_unsigned(51185, 16));
        tmp(82) := std_logic_vector(to_unsigned(50325, 16));
        tmp(83) := std_logic_vector(to_unsigned(49447, 16));
        tmp(84) := std_logic_vector(to_unsigned(48553, 16));
        tmp(85) := std_logic_vector(to_unsigned(47643, 16));
        tmp(86) := std_logic_vector(to_unsigned(46719, 16));
        tmp(87) := std_logic_vector(to_unsigned(45781, 16));
        tmp(88) := std_logic_vector(to_unsigned(44830, 16));
        tmp(89) := std_logic_vector(to_unsigned(43867, 16));
        tmp(90) := std_logic_vector(to_unsigned(42893, 16));
        tmp(91) := std_logic_vector(to_unsigned(41909, 16));
        tmp(92) := std_logic_vector(to_unsigned(40916, 16));
        tmp(93) := std_logic_vector(to_unsigned(39915, 16));
        tmp(94) := std_logic_vector(to_unsigned(38907, 16));
        tmp(95) := std_logic_vector(to_unsigned(37893, 16));
        tmp(96) := std_logic_vector(to_unsigned(36874, 16));
        tmp(97) := std_logic_vector(to_unsigned(35851, 16));
        tmp(98) := std_logic_vector(to_unsigned(34825, 16));
        tmp(99) := std_logic_vector(to_unsigned(33797, 16));
        tmp(100) := std_logic_vector(to_unsigned(32768, 16));
        tmp(101) := std_logic_vector(to_unsigned(31738, 16));
        tmp(102) := std_logic_vector(to_unsigned(30710, 16));
        tmp(103) := std_logic_vector(to_unsigned(29684, 16));
        tmp(104) := std_logic_vector(to_unsigned(28661, 16));
        tmp(105) := std_logic_vector(to_unsigned(27642, 16));
        tmp(106) := std_logic_vector(to_unsigned(26628, 16));
        tmp(107) := std_logic_vector(to_unsigned(25620, 16));
        tmp(108) := std_logic_vector(to_unsigned(24619, 16));
        tmp(109) := std_logic_vector(to_unsigned(23626, 16));
        tmp(110) := std_logic_vector(to_unsigned(22642, 16));
        tmp(111) := std_logic_vector(to_unsigned(21668, 16));
        tmp(112) := std_logic_vector(to_unsigned(20705, 16));
        tmp(113) := std_logic_vector(to_unsigned(19754, 16));
        tmp(114) := std_logic_vector(to_unsigned(18816, 16));
        tmp(115) := std_logic_vector(to_unsigned(17892, 16));
        tmp(116) := std_logic_vector(to_unsigned(16982, 16));
        tmp(117) := std_logic_vector(to_unsigned(16088, 16));
        tmp(118) := std_logic_vector(to_unsigned(15210, 16));
        tmp(119) := std_logic_vector(to_unsigned(14350, 16));
        tmp(120) := std_logic_vector(to_unsigned(13508, 16));
        tmp(121) := std_logic_vector(to_unsigned(12684, 16));
        tmp(122) := std_logic_vector(to_unsigned(11881, 16));
        tmp(123) := std_logic_vector(to_unsigned(11098, 16));
        tmp(124) := std_logic_vector(to_unsigned(10337, 16));
        tmp(125) := std_logic_vector(to_unsigned(9598, 16));
        tmp(126) := std_logic_vector(to_unsigned(8881, 16));
        tmp(127) := std_logic_vector(to_unsigned(8189, 16));
        tmp(128) := std_logic_vector(to_unsigned(7520, 16));
        tmp(129) := std_logic_vector(to_unsigned(6876, 16));
        tmp(130) := std_logic_vector(to_unsigned(6258, 16));
        tmp(131) := std_logic_vector(to_unsigned(5667, 16));
        tmp(132) := std_logic_vector(to_unsigned(5101, 16));
        tmp(133) := std_logic_vector(to_unsigned(4564, 16));
        tmp(134) := std_logic_vector(to_unsigned(4054, 16));
        tmp(135) := std_logic_vector(to_unsigned(3572, 16));
        tmp(136) := std_logic_vector(to_unsigned(3119, 16));
        tmp(137) := std_logic_vector(to_unsigned(2695, 16));
        tmp(138) := std_logic_vector(to_unsigned(2302, 16));
        tmp(139) := std_logic_vector(to_unsigned(1938, 16));
        tmp(140) := std_logic_vector(to_unsigned(1604, 16));
        tmp(141) := std_logic_vector(to_unsigned(1302, 16));
        tmp(142) := std_logic_vector(to_unsigned(1030, 16));
        tmp(143) := std_logic_vector(to_unsigned(790, 16));
        tmp(144) := std_logic_vector(to_unsigned(581, 16));
        tmp(145) := std_logic_vector(to_unsigned(404, 16));
        tmp(146) := std_logic_vector(to_unsigned(259, 16));
        tmp(147) := std_logic_vector(to_unsigned(146, 16));
        tmp(148) := std_logic_vector(to_unsigned(65, 16));
        tmp(149) := std_logic_vector(to_unsigned(17, 16));
        tmp(150) := std_logic_vector(to_unsigned(1, 16));
        tmp(151) := std_logic_vector(to_unsigned(17, 16));
        tmp(152) := std_logic_vector(to_unsigned(65, 16));
        tmp(153) := std_logic_vector(to_unsigned(146, 16));
        tmp(154) := std_logic_vector(to_unsigned(259, 16));
        tmp(155) := std_logic_vector(to_unsigned(404, 16));
        tmp(156) := std_logic_vector(to_unsigned(581, 16));
        tmp(157) := std_logic_vector(to_unsigned(790, 16));
        tmp(158) := std_logic_vector(to_unsigned(1030, 16));
        tmp(159) := std_logic_vector(to_unsigned(1302, 16));
        tmp(160) := std_logic_vector(to_unsigned(1604, 16));
        tmp(161) := std_logic_vector(to_unsigned(1938, 16));
        tmp(162) := std_logic_vector(to_unsigned(2302, 16));
        tmp(163) := std_logic_vector(to_unsigned(2695, 16));
        tmp(164) := std_logic_vector(to_unsigned(3119, 16));
        tmp(165) := std_logic_vector(to_unsigned(3572, 16));
        tmp(166) := std_logic_vector(to_unsigned(4054, 16));
        tmp(167) := std_logic_vector(to_unsigned(4564, 16));
        tmp(168) := std_logic_vector(to_unsigned(5101, 16));
        tmp(169) := std_logic_vector(to_unsigned(5667, 16));
        tmp(170) := std_logic_vector(to_unsigned(6258, 16));
        tmp(171) := std_logic_vector(to_unsigned(6876, 16));
        tmp(172) := std_logic_vector(to_unsigned(7520, 16));
        tmp(173) := std_logic_vector(to_unsigned(8189, 16));
        tmp(174) := std_logic_vector(to_unsigned(8881, 16));
        tmp(175) := std_logic_vector(to_unsigned(9598, 16));
        tmp(176) := std_logic_vector(to_unsigned(10337, 16));
        tmp(177) := std_logic_vector(to_unsigned(11098, 16));
        tmp(178) := std_logic_vector(to_unsigned(11881, 16));
        tmp(179) := std_logic_vector(to_unsigned(12684, 16));
        tmp(180) := std_logic_vector(to_unsigned(13508, 16));
        tmp(181) := std_logic_vector(to_unsigned(14350, 16));
        tmp(182) := std_logic_vector(to_unsigned(15210, 16));
        tmp(183) := std_logic_vector(to_unsigned(16088, 16));
        tmp(184) := std_logic_vector(to_unsigned(16982, 16));
        tmp(185) := std_logic_vector(to_unsigned(17892, 16));
        tmp(186) := std_logic_vector(to_unsigned(18816, 16));
        tmp(187) := std_logic_vector(to_unsigned(19754, 16));
        tmp(188) := std_logic_vector(to_unsigned(20705, 16));
        tmp(189) := std_logic_vector(to_unsigned(21668, 16));
        tmp(190) := std_logic_vector(to_unsigned(22642, 16));
        tmp(191) := std_logic_vector(to_unsigned(23626, 16));
        tmp(192) := std_logic_vector(to_unsigned(24619, 16));
        tmp(193) := std_logic_vector(to_unsigned(25620, 16));
        tmp(194) := std_logic_vector(to_unsigned(26628, 16));
        tmp(195) := std_logic_vector(to_unsigned(27642, 16));
        tmp(196) := std_logic_vector(to_unsigned(28661, 16));
        tmp(197) := std_logic_vector(to_unsigned(29684, 16));
        tmp(198) := std_logic_vector(to_unsigned(30710, 16));
        tmp(199) := std_logic_vector(to_unsigned(31738, 16));
        tmp(200) := std_logic_vector(to_unsigned(0, 16));
        tmp(201) := std_logic_vector(to_unsigned(0, 16));
        tmp(202) := std_logic_vector(to_unsigned(0, 16));
        tmp(203) := std_logic_vector(to_unsigned(0, 16));
        tmp(204) := std_logic_vector(to_unsigned(0, 16));
        tmp(205) := std_logic_vector(to_unsigned(0, 16));
        tmp(206) := std_logic_vector(to_unsigned(0, 16));
        tmp(207) := std_logic_vector(to_unsigned(0, 16));
        tmp(208) := std_logic_vector(to_unsigned(0, 16));
        tmp(209) := std_logic_vector(to_unsigned(0, 16));
        tmp(210) := std_logic_vector(to_unsigned(0, 16));
        tmp(211) := std_logic_vector(to_unsigned(0, 16));
        tmp(212) := std_logic_vector(to_unsigned(0, 16));
        tmp(213) := std_logic_vector(to_unsigned(0, 16));
        tmp(214) := std_logic_vector(to_unsigned(0, 16));
        tmp(215) := std_logic_vector(to_unsigned(0, 16));
        tmp(216) := std_logic_vector(to_unsigned(0, 16));
        tmp(217) := std_logic_vector(to_unsigned(0, 16));
        tmp(218) := std_logic_vector(to_unsigned(0, 16));
        tmp(219) := std_logic_vector(to_unsigned(0, 16));
        tmp(220) := std_logic_vector(to_unsigned(0, 16));
        tmp(221) := std_logic_vector(to_unsigned(0, 16));
        tmp(222) := std_logic_vector(to_unsigned(0, 16));
        tmp(223) := std_logic_vector(to_unsigned(0, 16));
        tmp(224) := std_logic_vector(to_unsigned(0, 16));
        tmp(225) := std_logic_vector(to_unsigned(0, 16));
        tmp(226) := std_logic_vector(to_unsigned(0, 16));
        tmp(227) := std_logic_vector(to_unsigned(0, 16));
        tmp(228) := std_logic_vector(to_unsigned(0, 16));
        tmp(229) := std_logic_vector(to_unsigned(0, 16));
        tmp(230) := std_logic_vector(to_unsigned(0, 16));
        tmp(231) := std_logic_vector(to_unsigned(0, 16));
        tmp(232) := std_logic_vector(to_unsigned(0, 16));
        tmp(233) := std_logic_vector(to_unsigned(0, 16));
        tmp(234) := std_logic_vector(to_unsigned(0, 16));
        tmp(235) := std_logic_vector(to_unsigned(0, 16));
        tmp(236) := std_logic_vector(to_unsigned(0, 16));
        tmp(237) := std_logic_vector(to_unsigned(0, 16));
        tmp(238) := std_logic_vector(to_unsigned(0, 16));
        tmp(239) := std_logic_vector(to_unsigned(0, 16));
        tmp(240) := std_logic_vector(to_unsigned(0, 16));
        tmp(241) := std_logic_vector(to_unsigned(0, 16));
        tmp(242) := std_logic_vector(to_unsigned(0, 16));
        tmp(243) := std_logic_vector(to_unsigned(0, 16));
        tmp(244) := std_logic_vector(to_unsigned(0, 16));
        tmp(245) := std_logic_vector(to_unsigned(0, 16));
        tmp(246) := std_logic_vector(to_unsigned(0, 16));
        tmp(247) := std_logic_vector(to_unsigned(0, 16));
        tmp(248) := std_logic_vector(to_unsigned(0, 16));
        tmp(249) := std_logic_vector(to_unsigned(0, 16));
        tmp(250) := std_logic_vector(to_unsigned(0, 16));
        tmp(251) := std_logic_vector(to_unsigned(0, 16));
        tmp(252) := std_logic_vector(to_unsigned(0, 16));
        tmp(253) := std_logic_vector(to_unsigned(0, 16));
        tmp(254) := std_logic_vector(to_unsigned(0, 16));
        tmp(255) := std_logic_vector(to_unsigned(0, 16));

            
            
            
            
            
            
		--end loop;
		return tmp;
	end init_rom;	 

	-- Declare the ROM signal and specify a default value.	Quartus Prime
	-- will create a memory initialization file (.mif) based on the 
	-- default value.
	signal rom : memory_t := init_rom;

begin

	process(clk)
	begin
	if(rising_edge(clk)) then
		q <= rom(addr);
	end if;
	end process;

end rtl;
