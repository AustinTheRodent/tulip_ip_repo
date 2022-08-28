
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
  30:	35 40 cc 02 	mov	#716,	r5	;#0x02cc
  34:	36 40 cc 02 	mov	#716,	r6	;#0x02cc
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
  72:	07 12       	push	r7		;
  74:	06 12       	push	r6		;
  76:	3c 40 00 4b 	mov	#19200,	r12	;#0x4b00
  7a:	4d 43       	clr.b	r13		;
  7c:	b0 12 68 01 	call	#360		;#0x0168
  80:	3a 40 fc 01 	mov	#508,	r10	;#0x01fc
  84:	3c 40 a4 02 	mov	#676,	r12	;#0x02a4
  88:	8a 12       	call	r10		;
  8a:	3c 40 c0 02 	mov	#704,	r12	;#0x02c0
  8e:	8a 12       	call	r10		;
  90:	6c 42       	mov.b	#4,	r12	;r2 As==10
  92:	b0 12 06 01 	call	#262		;#0x0106
  96:	3a 40 4a 01 	mov	#330,	r10	;#0x014a
  9a:	8a 12       	call	r10		;
  9c:	36 40 2e 01 	mov	#302,	r6	;#0x012e
  a0:	37 40 52 01 	mov	#338,	r7	;#0x0152
  a4:	38 40 00 01 	mov	#256,	r8	;#0x0100

000000a8 <.L2>:
  a8:	4c 43       	clr.b	r12		;
  aa:	86 12       	call	r6		;
  ac:	3c 40 ad de 	mov	#-8531,	r12	;#0xdead
  b0:	87 12       	call	r7		;
  b2:	8a 12       	call	r10		;
  b4:	3c 40 aa aa 	mov	#-21846,r12	;#0xaaaa
  b8:	88 12       	call	r8		;
  ba:	39 40 d4 00 	mov	#212,	r9	;#0x00d4
  be:	7c 40 96 00 	mov.b	#150,	r12	;#0x0096
  c2:	89 12       	call	r9		;
  c4:	3c 40 55 55 	mov	#21845,	r12	;#0x5555
  c8:	88 12       	call	r8		;
  ca:	7c 40 96 00 	mov.b	#150,	r12	;#0x0096
  ce:	89 12       	call	r9		;
  d0:	30 40 a8 00 	br	#0x00a8		;

000000d4 <neo430_cpu_delay_ms>:
  d4:	1e 42 fe ff 	mov	&0xfffe,r14	;0xfffe
  d8:	0f 43       	clr	r15		;
  da:	0b 4e       	mov	r14,	r11	;
  dc:	0b 5e       	add	r14,	r11	;
  de:	0d 4f       	mov	r15,	r13	;
  e0:	0d 6f       	addc	r15,	r13	;
  e2:	0e 4c       	mov	r12,	r14	;
  e4:	0f 43       	clr	r15		;
  e6:	0c 4b       	mov	r11,	r12	;
  e8:	b0 12 52 02 	call	#594		;#0x0252

000000ec <.L17>:
  ec:	3c 53       	add	#-1,	r12	;r3 As==11
  ee:	3d 63       	addc	#-1,	r13	;r3 As==11
  f0:	3c 93       	cmp	#-1,	r12	;r3 As==11
  f2:	03 20       	jnz	$+8      	;abs 0xfa
  f4:	3d 93       	cmp	#-1,	r13	;r3 As==11
  f6:	01 20       	jnz	$+4      	;abs 0xfa
  f8:	30 41       	ret			

000000fa <.L18>:
  fa:	03 43       	nop			
  fc:	30 40 ec 00 	br	#0x00ec		;

00000100 <neo430_gpio_port_set>:
 100:	82 4c ac ff 	mov	r12,	&0xffac	;
 104:	30 41       	ret			

00000106 <neo430_spi_enable>:
 106:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 10a:	3d 40 a4 ff 	mov	#-92,	r13	;#0xffa4
 10e:	8d 43 00 00 	mov	#0,	0(r13)	;r3 As==00
 112:	0c 5c       	rla	r12		;
 114:	0c 5c       	rla	r12		;
 116:	0c 5c       	rla	r12		;
 118:	0c 5c       	rla	r12		;
 11a:	0c 5c       	rla	r12		;
 11c:	0c 5c       	rla	r12		;
 11e:	0c 5c       	rla	r12		;
 120:	0c 5c       	rla	r12		;
 122:	0c 5c       	rla	r12		;
 124:	3c d0 40 00 	bis	#64,	r12	;#0x0040
 128:	8d 4c 00 00 	mov	r12,	0(r13)	;
 12c:	30 41       	ret			

0000012e <neo430_spi_cs_en>:
 12e:	0a 12       	push	r10		;
 130:	09 12       	push	r9		;
 132:	4d 4c       	mov.b	r12,	r13	;
 134:	3a 40 a4 ff 	mov	#-92,	r10	;#0xffa4
 138:	29 4a       	mov	@r10,	r9	;
 13a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 13c:	b0 12 40 02 	call	#576		;#0x0240
 140:	0c d9       	bis	r9,	r12	;
 142:	8a 4c 00 00 	mov	r12,	0(r10)	;
 146:	30 40 36 02 	br	#0x0236		;

0000014a <neo430_spi_cs_dis>:
 14a:	b2 f0 c0 ff 	and	#-64,	&0xffa4	;#0xffc0
 14e:	a4 ff 
 150:	30 41       	ret			

00000152 <neo430_spi_trans>:
 152:	3d 40 a6 ff 	mov	#-90,	r13	;#0xffa6
 156:	8d 4c 00 00 	mov	r12,	0(r13)	;
 15a:	3e 40 a4 ff 	mov	#-92,	r14	;#0xffa4

0000015e <.L6>:
 15e:	2c 4e       	mov	@r14,	r12	;
 160:	0c 93       	cmp	#0,	r12	;r3 As==00
 162:	fd 3b       	jl	$-4      	;abs 0x15e
 164:	2c 4d       	mov	@r13,	r12	;
 166:	30 41       	ret			

00000168 <neo430_uart_setup>:
 168:	0a 12       	push	r10		;
 16a:	09 12       	push	r9		;
 16c:	1a 42 fc ff 	mov	&0xfffc,r10	;0xfffc
 170:	1b 42 fe ff 	mov	&0xfffe,r11	;0xfffe
 174:	0e 4c       	mov	r12,	r14	;
 176:	0e 5c       	add	r12,	r14	;
 178:	0f 4d       	mov	r13,	r15	;
 17a:	0f 6d       	addc	r13,	r15	;
 17c:	4c 43       	clr.b	r12		;
 17e:	09 4f       	mov	r15,	r9	;

00000180 <.L2>:
 180:	0b 9f       	cmp	r15,	r11	;
 182:	04 28       	jnc	$+10     	;abs 0x18c
 184:	09 9b       	cmp	r11,	r9	;
 186:	1b 20       	jnz	$+56     	;abs 0x1be
 188:	0a 9e       	cmp	r14,	r10	;
 18a:	19 2c       	jc	$+52     	;abs 0x1be

0000018c <.L10>:
 18c:	4a 43       	clr.b	r10		;
 18e:	79 40 03 00 	mov.b	#3,	r9	;

00000192 <.L5>:
 192:	7d 40 ff 00 	mov.b	#255,	r13	;#0x00ff
 196:	0d 9c       	cmp	r12,	r13	;
 198:	17 28       	jnc	$+48     	;abs 0x1c8
 19a:	82 43 a0 ff 	mov	#0,	&0xffa0	;r3 As==00
 19e:	0d 4a       	mov	r10,	r13	;
 1a0:	0d 5a       	add	r10,	r13	;
 1a2:	0d 5d       	rla	r13		;
 1a4:	0d 5d       	rla	r13		;
 1a6:	0d 5d       	rla	r13		;
 1a8:	0d 5d       	rla	r13		;
 1aa:	0d 5d       	rla	r13		;
 1ac:	0d 5d       	rla	r13		;
 1ae:	0d 5d       	rla	r13		;
 1b0:	0d dc       	bis	r12,	r13	;
 1b2:	3d d0 00 10 	bis	#4096,	r13	;#0x1000
 1b6:	82 4d a0 ff 	mov	r13,	&0xffa0	;
 1ba:	30 40 36 02 	br	#0x0236		;

000001be <.L3>:
 1be:	0a 8e       	sub	r14,	r10	;
 1c0:	0b 7f       	subc	r15,	r11	;
 1c2:	1c 53       	inc	r12		;
 1c4:	30 40 80 01 	br	#0x0180		;

000001c8 <.L9>:
 1c8:	6a 93       	cmp.b	#2,	r10	;r3 As==10
 1ca:	02 24       	jz	$+6      	;abs 0x1d0
 1cc:	6a 92       	cmp.b	#4,	r10	;r2 As==10
 1ce:	08 20       	jnz	$+18     	;abs 0x1e0

000001d0 <.L6>:
 1d0:	0d 49       	mov	r9,	r13	;
 1d2:	b0 12 4c 02 	call	#588		;#0x024c

000001d6 <.L8>:
 1d6:	5a 53       	inc.b	r10		;
 1d8:	3a f0 ff 00 	and	#255,	r10	;#0x00ff
 1dc:	30 40 92 01 	br	#0x0192		;

000001e0 <.L7>:
 1e0:	12 c3       	clrc			
 1e2:	0c 10       	rrc	r12		;
 1e4:	30 40 d6 01 	br	#0x01d6		;

000001e8 <neo430_uart_putc>:
 1e8:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 1ec:	3e 40 a0 ff 	mov	#-96,	r14	;#0xffa0

000001f0 <.L17>:
 1f0:	2d 4e       	mov	@r14,	r13	;
 1f2:	0d 93       	cmp	#0,	r13	;r3 As==00
 1f4:	fd 3b       	jl	$-4      	;abs 0x1f0
 1f6:	82 4c a2 ff 	mov	r12,	&0xffa2	;
 1fa:	30 41       	ret			

000001fc <neo430_uart_br_print>:
 1fc:	0a 12       	push	r10		;
 1fe:	09 12       	push	r9		;
 200:	08 12       	push	r8		;
 202:	07 12       	push	r7		;
 204:	09 4c       	mov	r12,	r9	;
 206:	38 40 e8 01 	mov	#488,	r8	;#0x01e8
 20a:	77 40 0d 00 	mov.b	#13,	r7	;#0x000d

0000020e <.L28>:
 20e:	6a 49       	mov.b	@r9,	r10	;
 210:	0a 93       	cmp	#0,	r10	;r3 As==00
 212:	02 20       	jnz	$+6      	;abs 0x218
 214:	30 40 32 02 	br	#0x0232		;

00000218 <.L30>:
 218:	3a 90 0a 00 	cmp	#10,	r10	;#0x000a
 21c:	02 20       	jnz	$+6      	;abs 0x222
 21e:	4c 47       	mov.b	r7,	r12	;
 220:	88 12       	call	r8		;

00000222 <.L29>:
 222:	4c 4a       	mov.b	r10,	r12	;
 224:	88 12       	call	r8		;
 226:	19 53       	inc	r9		;
 228:	30 40 0e 02 	br	#0x020e		;

0000022c <__mspabi_func_epilog_7>:
 22c:	34 41       	pop	r4		;

0000022e <__mspabi_func_epilog_6>:
 22e:	35 41       	pop	r5		;

00000230 <__mspabi_func_epilog_5>:
 230:	36 41       	pop	r6		;

00000232 <__mspabi_func_epilog_4>:
 232:	37 41       	pop	r7		;

00000234 <__mspabi_func_epilog_3>:
 234:	38 41       	pop	r8		;

00000236 <__mspabi_func_epilog_2>:
 236:	39 41       	pop	r9		;

00000238 <__mspabi_func_epilog_1>:
 238:	3a 41       	pop	r10		;
 23a:	30 41       	ret			

0000023c <.L11>:
 23c:	3d 53       	add	#-1,	r13	;r3 As==11
 23e:	0c 5c       	rla	r12		;

00000240 <__mspabi_slli>:
 240:	0d 93       	cmp	#0,	r13	;r3 As==00
 242:	fc 23       	jnz	$-6      	;abs 0x23c
 244:	30 41       	ret			

00000246 <.L11>:
 246:	3d 53       	add	#-1,	r13	;r3 As==11
 248:	12 c3       	clrc			
 24a:	0c 10       	rrc	r12		;

0000024c <__mspabi_srli>:
 24c:	0d 93       	cmp	#0,	r13	;r3 As==00
 24e:	fb 23       	jnz	$-8      	;abs 0x246
 250:	30 41       	ret			

00000252 <__mspabi_mpyl>:
 252:	0a 12       	push	r10		;

00000254 <.LCFI0>:
 254:	09 12       	push	r9		;

00000256 <.LCFI1>:
 256:	08 12       	push	r8		;

00000258 <.LCFI2>:
 258:	07 12       	push	r7		;

0000025a <.LCFI3>:
 25a:	06 12       	push	r6		;

0000025c <.LCFI4>:
 25c:	0a 4c       	mov	r12,	r10	;
 25e:	0b 4d       	mov	r13,	r11	;

00000260 <.LVL1>:
 260:	7d 40 21 00 	mov.b	#33,	r13	;#0x0021

00000264 <.Loc.30.1>:
 264:	48 43       	clr.b	r8		;
 266:	49 43       	clr.b	r9		;

00000268 <.L2>:
 268:	0c 4e       	mov	r14,	r12	;
 26a:	0c df       	bis	r15,	r12	;
 26c:	0c 93       	cmp	#0,	r12	;r3 As==00
 26e:	05 24       	jz	$+12     	;abs 0x27a
 270:	7d 53       	add.b	#-1,	r13	;r3 As==11

00000272 <.LVL3>:
 272:	3d f0 ff 00 	and	#255,	r13	;#0x00ff

00000276 <.Loc.34.1>:
 276:	0d 93       	cmp	#0,	r13	;r3 As==00
 278:	04 20       	jnz	$+10     	;abs 0x282

0000027a <.L1>:
 27a:	0c 48       	mov	r8,	r12	;
 27c:	0d 49       	mov	r9,	r13	;
 27e:	30 40 30 02 	br	#0x0230		;

00000282 <.L6>:
 282:	0c 4e       	mov	r14,	r12	;
 284:	5c f3       	and.b	#1,	r12	;r3 As==01

00000286 <.Loc.36.1>:
 286:	0c 93       	cmp	#0,	r12	;r3 As==00
 288:	02 24       	jz	$+6      	;abs 0x28e

0000028a <.Loc.37.1>:
 28a:	08 5a       	add	r10,	r8	;

0000028c <.LVL4>:
 28c:	09 6b       	addc	r11,	r9	;

0000028e <.L3>:
 28e:	06 4a       	mov	r10,	r6	;
 290:	07 4b       	mov	r11,	r7	;
 292:	06 5a       	add	r10,	r6	;
 294:	07 6b       	addc	r11,	r7	;
 296:	0a 46       	mov	r6,	r10	;

00000298 <.LVL6>:
 298:	0b 47       	mov	r7,	r11	;

0000029a <.LVL7>:
 29a:	12 c3       	clrc			
 29c:	0f 10       	rrc	r15		;
 29e:	0e 10       	rrc	r14		;

000002a0 <.LVL8>:
 2a0:	30 40 68 02 	br	#0x0268		;

Disassembly of section .rodata:

000002a4 <_etext-0x28>:
 2a4:	0a 42       	mov	r2,	r10	;
 2a6:	6c 69       	addc.b	@r9,	r12	;
 2a8:	6e 6b       	addc.b	@r11,	r14	;
 2aa:	69 6e       	addc.b	@r14,	r9	;
 2ac:	67 20       	jnz	$+208    	;abs 0x37c
 2ae:	4c 45       	mov.b	r5,	r12	;
 2b0:	44 20       	jnz	$+138    	;abs 0x33a
 2b2:	64 65       	addc.b	@r5,	r4	;
 2b4:	6d 6f       	addc.b	@r15,	r13	;
 2b6:	20 70       	subc	@r0,	r0	;
 2b8:	72 6f       	addc.b	@r15+,	r2	;
 2ba:	67 72       	subc.b	#4,	r7	;r2 As==10
 2bc:	61 6d       	addc.b	@r13,	r1	;
 2be:	0a 00       	mova	@r0,	r10	;
 2c0:	0a 53       	add	#0,	r10	;r3 As==00
 2c2:	65 74       	subc.b	@r4,	r5	;
 2c4:	75 70 20 53 	subc.b	#21280,	r5	;#0x5320
 2c8:	50 49 0a 00 	br	10(r9)		;

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