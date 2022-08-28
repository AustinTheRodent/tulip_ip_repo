
main.elf:     file format elf32-msp430


Disassembly of section .text:

00000000 <__crt0_begin>:
   0:	38 40 00 c0 	mov	#-16384,r8	;#0xc000
   4:	11 42 fa ff 	mov	&0xfffa,r1	;0xfffa
   8:	02 43       	clr	r2		;
   a:	01 58       	add	r8,	r1	;
   c:	21 83       	decd	r1		;
   e:	b2 40 00 47 	mov	#18176,	&0xffb8	;#0x4700
  12:	b8 ff 
  14:	39 40 80 ff 	mov	#-128,	r9	;#0xff80

00000018 <__crt0_clr_io>:
  18:	09 93       	cmp	#0,	r9	;r3 As==00
  1a:	04 24       	jz	$+10     	;abs 0x24
  1c:	89 43 00 00 	mov	#0,	0(r9)	;r3 As==00
  20:	29 53       	incd	r9		;
  22:	fa 3f       	jmp	$-10     	;abs 0x18

00000024 <__crt0_clr_dmem>:
  24:	01 98       	cmp	r8,	r1	;
  26:	04 24       	jz	$+10     	;abs 0x30
  28:	88 43 00 00 	mov	#0,	0(r8)	;r3 As==00
  2c:	28 53       	incd	r8		;
  2e:	fa 3f       	jmp	$-10     	;abs 0x24

00000030 <__crt0_clr_dmem_end>:
  30:	35 40 28 02 	mov	#552,	r5	;#0x0228
  34:	36 40 28 02 	mov	#552,	r6	;#0x0228
  38:	37 40 08 c0 	mov	#-16376,r7	;#0xc008

0000003c <__crt0_cpy_data>:
  3c:	06 95       	cmp	r5,	r6	;
  3e:	04 24       	jz	$+10     	;abs 0x48
  40:	b7 45 00 00 	mov	@r5+,	0(r7)	;
  44:	27 53       	incd	r7		;
  46:	fa 3f       	jmp	$-10     	;abs 0x3c

00000048 <__crt0_cpy_data_end>:
  48:	32 40 00 40 	mov	#16384,	r2	;#0x4000
  4c:	04 43       	clr	r4		;
  4e:	0a 43       	clr	r10		;
  50:	0b 43       	clr	r11		;
  52:	0c 43       	clr	r12		;
  54:	0d 43       	clr	r13		;
  56:	0e 43       	clr	r14		;
  58:	0f 43       	clr	r15		;

0000005a <__crt0_start_main>:
  5a:	b0 12 6c 00 	call	#108		;#0x006c

0000005e <__crt0_this_is_the_end>:
  5e:	02 43       	clr	r2		;
  60:	b2 40 00 47 	mov	#18176,	&0xffb8	;#0x4700
  64:	b8 ff 
  66:	32 40 10 00 	mov	#16,	r2	;#0x0010
  6a:	03 43       	nop			

0000006c <main>:
  6c:	0a 12       	push	r10		;
  6e:	09 12       	push	r9		;
  70:	08 12       	push	r8		;
  72:	3c 40 00 4b 	mov	#19200,	r12	;#0x4b00
  76:	4d 43       	clr.b	r13		;
  78:	b0 12 da 00 	call	#218		;#0x00da
  7c:	3c 40 0c 02 	mov	#524,	r12	;#0x020c
  80:	b0 12 6e 01 	call	#366		;#0x016e
  84:	38 40 d4 00 	mov	#212,	r8	;#0x00d4
  88:	3a 40 a8 00 	mov	#168,	r10	;#0x00a8
  8c:	79 40 96 00 	mov.b	#150,	r9	;#0x0096

00000090 <.L2>:
  90:	3c 40 aa aa 	mov	#-21846,r12	;#0xaaaa
  94:	88 12       	call	r8		;
  96:	0c 49       	mov	r9,	r12	;
  98:	8a 12       	call	r10		;
  9a:	3c 40 55 55 	mov	#21845,	r12	;#0x5555
  9e:	88 12       	call	r8		;
  a0:	0c 49       	mov	r9,	r12	;
  a2:	8a 12       	call	r10		;
  a4:	30 40 90 00 	br	#0x0090		;

000000a8 <neo430_cpu_delay_ms>:
  a8:	1e 42 fe ff 	mov	&0xfffe,r14	;0xfffe
  ac:	0f 43       	clr	r15		;
  ae:	0b 4e       	mov	r14,	r11	;
  b0:	0b 5e       	add	r14,	r11	;
  b2:	0d 4f       	mov	r15,	r13	;
  b4:	0d 6f       	addc	r15,	r13	;
  b6:	0e 4c       	mov	r12,	r14	;
  b8:	0f 43       	clr	r15		;
  ba:	0c 4b       	mov	r11,	r12	;
  bc:	b0 12 ba 01 	call	#442		;#0x01ba

000000c0 <.L17>:
  c0:	3c 53       	add	#-1,	r12	;r3 As==11
  c2:	3d 63       	addc	#-1,	r13	;r3 As==11
  c4:	3c 93       	cmp	#-1,	r12	;r3 As==11
  c6:	03 20       	jnz	$+8      	;abs 0xce
  c8:	3d 93       	cmp	#-1,	r13	;r3 As==11
  ca:	01 20       	jnz	$+4      	;abs 0xce
  cc:	30 41       	ret			

000000ce <.L18>:
  ce:	03 43       	nop			
  d0:	30 40 c0 00 	br	#0x00c0		;

000000d4 <neo430_gpio_port_set>:
  d4:	82 4c ac ff 	mov	r12,	&0xffac	;
  d8:	30 41       	ret			

000000da <neo430_uart_setup>:
  da:	0a 12       	push	r10		;
  dc:	09 12       	push	r9		;
  de:	1a 42 fc ff 	mov	&0xfffc,r10	;0xfffc
  e2:	1b 42 fe ff 	mov	&0xfffe,r11	;0xfffe
  e6:	0e 4c       	mov	r12,	r14	;
  e8:	0e 5c       	add	r12,	r14	;
  ea:	0f 4d       	mov	r13,	r15	;
  ec:	0f 6d       	addc	r13,	r15	;
  ee:	4c 43       	clr.b	r12		;
  f0:	09 4f       	mov	r15,	r9	;

000000f2 <.L2>:
  f2:	0b 9f       	cmp	r15,	r11	;
  f4:	04 28       	jnc	$+10     	;abs 0xfe
  f6:	09 9b       	cmp	r11,	r9	;
  f8:	1b 20       	jnz	$+56     	;abs 0x130
  fa:	0a 9e       	cmp	r14,	r10	;
  fc:	19 2c       	jc	$+52     	;abs 0x130

000000fe <.L10>:
  fe:	4a 43       	clr.b	r10		;
 100:	79 40 03 00 	mov.b	#3,	r9	;

00000104 <.L5>:
 104:	7d 40 ff 00 	mov.b	#255,	r13	;#0x00ff
 108:	0d 9c       	cmp	r12,	r13	;
 10a:	17 28       	jnc	$+48     	;abs 0x13a
 10c:	82 43 a0 ff 	mov	#0,	&0xffa0	;r3 As==00
 110:	0d 4a       	mov	r10,	r13	;
 112:	0d 5a       	add	r10,	r13	;
 114:	0d 5d       	rla	r13		;
 116:	0d 5d       	rla	r13		;
 118:	0d 5d       	rla	r13		;
 11a:	0d 5d       	rla	r13		;
 11c:	0d 5d       	rla	r13		;
 11e:	0d 5d       	rla	r13		;
 120:	0d 5d       	rla	r13		;
 122:	0d dc       	bis	r12,	r13	;
 124:	3d d0 00 10 	bis	#4096,	r13	;#0x1000
 128:	82 4d a0 ff 	mov	r13,	&0xffa0	;
 12c:	30 40 a8 01 	br	#0x01a8		;

00000130 <.L3>:
 130:	0a 8e       	sub	r14,	r10	;
 132:	0b 7f       	subc	r15,	r11	;
 134:	1c 53       	inc	r12		;
 136:	30 40 f2 00 	br	#0x00f2		;

0000013a <.L9>:
 13a:	6a 93       	cmp.b	#2,	r10	;r3 As==10
 13c:	02 24       	jz	$+6      	;abs 0x142
 13e:	6a 92       	cmp.b	#4,	r10	;r2 As==10
 140:	08 20       	jnz	$+18     	;abs 0x152

00000142 <.L6>:
 142:	0d 49       	mov	r9,	r13	;
 144:	b0 12 b4 01 	call	#436		;#0x01b4

00000148 <.L8>:
 148:	5a 53       	inc.b	r10		;
 14a:	3a f0 ff 00 	and	#255,	r10	;#0x00ff
 14e:	30 40 04 01 	br	#0x0104		;

00000152 <.L7>:
 152:	12 c3       	clrc			
 154:	0c 10       	rrc	r12		;
 156:	30 40 48 01 	br	#0x0148		;

0000015a <neo430_uart_putc>:
 15a:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 15e:	3e 40 a0 ff 	mov	#-96,	r14	;#0xffa0

00000162 <.L17>:
 162:	2d 4e       	mov	@r14,	r13	;
 164:	0d 93       	cmp	#0,	r13	;r3 As==00
 166:	fd 3b       	jl	$-4      	;abs 0x162
 168:	82 4c a2 ff 	mov	r12,	&0xffa2	;
 16c:	30 41       	ret			

0000016e <neo430_uart_br_print>:
 16e:	0a 12       	push	r10		;
 170:	09 12       	push	r9		;
 172:	08 12       	push	r8		;
 174:	07 12       	push	r7		;
 176:	09 4c       	mov	r12,	r9	;
 178:	38 40 5a 01 	mov	#346,	r8	;#0x015a
 17c:	77 40 0d 00 	mov.b	#13,	r7	;#0x000d

00000180 <.L28>:
 180:	6a 49       	mov.b	@r9,	r10	;
 182:	0a 93       	cmp	#0,	r10	;r3 As==00
 184:	02 20       	jnz	$+6      	;abs 0x18a
 186:	30 40 a4 01 	br	#0x01a4		;

0000018a <.L30>:
 18a:	3a 90 0a 00 	cmp	#10,	r10	;#0x000a
 18e:	02 20       	jnz	$+6      	;abs 0x194
 190:	4c 47       	mov.b	r7,	r12	;
 192:	88 12       	call	r8		;

00000194 <.L29>:
 194:	4c 4a       	mov.b	r10,	r12	;
 196:	88 12       	call	r8		;
 198:	19 53       	inc	r9		;
 19a:	30 40 80 01 	br	#0x0180		;

0000019e <__mspabi_func_epilog_7>:
 19e:	34 41       	pop	r4		;

000001a0 <__mspabi_func_epilog_6>:
 1a0:	35 41       	pop	r5		;

000001a2 <__mspabi_func_epilog_5>:
 1a2:	36 41       	pop	r6		;

000001a4 <__mspabi_func_epilog_4>:
 1a4:	37 41       	pop	r7		;

000001a6 <__mspabi_func_epilog_3>:
 1a6:	38 41       	pop	r8		;

000001a8 <__mspabi_func_epilog_2>:
 1a8:	39 41       	pop	r9		;

000001aa <__mspabi_func_epilog_1>:
 1aa:	3a 41       	pop	r10		;
 1ac:	30 41       	ret			

000001ae <.L11>:
 1ae:	3d 53       	add	#-1,	r13	;r3 As==11
 1b0:	12 c3       	clrc			
 1b2:	0c 10       	rrc	r12		;

000001b4 <__mspabi_srli>:
 1b4:	0d 93       	cmp	#0,	r13	;r3 As==00
 1b6:	fb 23       	jnz	$-8      	;abs 0x1ae
 1b8:	30 41       	ret			

000001ba <__mspabi_mpyl>:
 1ba:	0a 12       	push	r10		;

000001bc <.LCFI0>:
 1bc:	09 12       	push	r9		;

000001be <.LCFI1>:
 1be:	08 12       	push	r8		;

000001c0 <.LCFI2>:
 1c0:	07 12       	push	r7		;

000001c2 <.LCFI3>:
 1c2:	06 12       	push	r6		;

000001c4 <.LCFI4>:
 1c4:	0a 4c       	mov	r12,	r10	;
 1c6:	0b 4d       	mov	r13,	r11	;

000001c8 <.LVL1>:
 1c8:	7d 40 21 00 	mov.b	#33,	r13	;#0x0021

000001cc <.Loc.30.1>:
 1cc:	48 43       	clr.b	r8		;
 1ce:	49 43       	clr.b	r9		;

000001d0 <.L2>:
 1d0:	0c 4e       	mov	r14,	r12	;
 1d2:	0c df       	bis	r15,	r12	;
 1d4:	0c 93       	cmp	#0,	r12	;r3 As==00
 1d6:	05 24       	jz	$+12     	;abs 0x1e2
 1d8:	7d 53       	add.b	#-1,	r13	;r3 As==11

000001da <.LVL3>:
 1da:	3d f0 ff 00 	and	#255,	r13	;#0x00ff

000001de <.Loc.34.1>:
 1de:	0d 93       	cmp	#0,	r13	;r3 As==00
 1e0:	04 20       	jnz	$+10     	;abs 0x1ea

000001e2 <.L1>:
 1e2:	0c 48       	mov	r8,	r12	;
 1e4:	0d 49       	mov	r9,	r13	;
 1e6:	30 40 a2 01 	br	#0x01a2		;

000001ea <.L6>:
 1ea:	0c 4e       	mov	r14,	r12	;
 1ec:	5c f3       	and.b	#1,	r12	;r3 As==01

000001ee <.Loc.36.1>:
 1ee:	0c 93       	cmp	#0,	r12	;r3 As==00
 1f0:	02 24       	jz	$+6      	;abs 0x1f6

000001f2 <.Loc.37.1>:
 1f2:	08 5a       	add	r10,	r8	;

000001f4 <.LVL4>:
 1f4:	09 6b       	addc	r11,	r9	;

000001f6 <.L3>:
 1f6:	06 4a       	mov	r10,	r6	;
 1f8:	07 4b       	mov	r11,	r7	;
 1fa:	06 5a       	add	r10,	r6	;
 1fc:	07 6b       	addc	r11,	r7	;
 1fe:	0a 46       	mov	r6,	r10	;

00000200 <.LVL6>:
 200:	0b 47       	mov	r7,	r11	;

00000202 <.LVL7>:
 202:	12 c3       	clrc			
 204:	0f 10       	rrc	r15		;
 206:	0e 10       	rrc	r14		;

00000208 <.LVL8>:
 208:	30 40 d0 01 	br	#0x01d0		;

Disassembly of section .rodata:

0000020c <_etext-0x1c>:
 20c:	0a 42       	mov	r2,	r10	;
 20e:	6c 69       	addc.b	@r9,	r12	;
 210:	6e 6b       	addc.b	@r11,	r14	;
 212:	69 6e       	addc.b	@r14,	r9	;
 214:	67 20       	jnz	$+208    	;abs 0x2e4
 216:	4c 45       	mov.b	r5,	r12	;
 218:	44 20       	jnz	$+138    	;abs 0x2a2
 21a:	64 65       	addc.b	@r5,	r4	;
 21c:	6d 6f       	addc.b	@r15,	r13	;
 21e:	20 70       	subc	@r0,	r0	;
 220:	72 6f       	addc.b	@r15+,	r2	;
 222:	67 72       	subc.b	#4,	r7	;r2 As==10
 224:	61 6d       	addc.b	@r13,	r1	;
 226:	0a 00       	mova	@r0,	r10	;

Disassembly of section .MP430.attributes:

00000000 <.MP430.attributes>:
   0:	41 16       	popm.a	#5,	r5	;20-bit words
   2:	00 00       	beq			
   4:	00 6d       	addc	r13,	r0	;
   6:	
Disassembly of section .comment:

00000000 <.comment>:
   0:	47 43       	clr.b	r7		;
   2:	43 3a       	jl	$-888    	;abs 0xfffffc8a
   4:	20 28       	jnc	$+66     	;abs 0x46
   6:	4d 69       	addc.b	r9,	r13	;
   8:	74 74       	subc.b	@r4+,	r4	;
   a:	6f 20       	jnz	$+224    	;abs 0xea
   c:	