
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
  30:	35 40 18 0e 	mov	#3608,	r5	;#0x0e18
  34:	36 40 18 0e 	mov	#3608,	r6	;#0x0e18
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
  5a:	b0 12 74 03 	call	#884		;#0x0374

0000005e <__crt0_this_is_the_end>:
  5e:	02 43       	clr	r2		;
  60:	b2 40 00 47 	mov	#18176,	&0xffb8	;#0x4700
  64:	b8 ff 
  66:	32 40 10 00 	mov	#16,	r2	;#0x0010
  6a:	03 43       	nop			

0000006c <sdram_reset>:
  6c:	0a 12       	push	r10		;
  6e:	3a 40 ba 07 	mov	#1978,	r10	;#0x07ba
  72:	5e 43       	mov.b	#1,	r14	;r3 As==01
  74:	7d 40 18 00 	mov.b	#24,	r13	;#0x0018
  78:	4c 4e       	mov.b	r14,	r12	;
  7a:	8a 12       	call	r10		;
  7c:	4e 43       	clr.b	r14		;
  7e:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
  82:	5c 43       	mov.b	#1,	r12	;r3 As==01
  84:	8a 12       	call	r10		;
  86:	5e 43       	mov.b	#1,	r14	;r3 As==01
  88:	7d 40 1b 00 	mov.b	#27,	r13	;#0x001b
  8c:	4c 4e       	mov.b	r14,	r12	;
  8e:	8a 12       	call	r10		;
  90:	5e 43       	mov.b	#1,	r14	;r3 As==01
  92:	7d 40 16 00 	mov.b	#22,	r13	;#0x0016
  96:	4c 4e       	mov.b	r14,	r12	;
  98:	8a 12       	call	r10		;
  9a:	5e 43       	mov.b	#1,	r14	;r3 As==01
  9c:	7d 40 17 00 	mov.b	#23,	r13	;#0x0017
  a0:	4c 4e       	mov.b	r14,	r12	;
  a2:	8a 12       	call	r10		;
  a4:	5e 43       	mov.b	#1,	r14	;r3 As==01
  a6:	7d 40 1a 00 	mov.b	#26,	r13	;#0x001a
  aa:	4c 4e       	mov.b	r14,	r12	;
  ac:	8a 12       	call	r10		;
  ae:	4e 43       	clr.b	r14		;
  b0:	7d 40 11 00 	mov.b	#17,	r13	;#0x0011
  b4:	5c 43       	mov.b	#1,	r12	;r3 As==01
  b6:	8a 12       	call	r10		;
  b8:	4e 43       	clr.b	r14		;
  ba:	7d 40 14 00 	mov.b	#20,	r13	;#0x0014
  be:	5c 43       	mov.b	#1,	r12	;r3 As==01
  c0:	8a 12       	call	r10		;
  c2:	4e 43       	clr.b	r14		;
  c4:	7d 40 12 00 	mov.b	#18,	r13	;#0x0012
  c8:	5c 43       	mov.b	#1,	r12	;r3 As==01
  ca:	8a 12       	call	r10		;
  cc:	7e 40 03 00 	mov.b	#3,	r14	;
  d0:	7d 40 15 00 	mov.b	#21,	r13	;#0x0015
  d4:	5c 43       	mov.b	#1,	r12	;r3 As==01
  d6:	8a 12       	call	r10		;
  d8:	4e 43       	clr.b	r14		;
  da:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
  de:	5c 43       	mov.b	#1,	r12	;r3 As==01
  e0:	8a 12       	call	r10		;
  e2:	5e 43       	mov.b	#1,	r14	;r3 As==01
  e4:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
  e8:	4c 4e       	mov.b	r14,	r12	;
  ea:	8a 12       	call	r10		;
  ec:	4e 43       	clr.b	r14		;
  ee:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
  f2:	5c 43       	mov.b	#1,	r12	;r3 As==01
  f4:	8a 12       	call	r10		;
  f6:	3a 41       	pop	r10		;
  f8:	30 41       	ret			

000000fa <sdram_activate_row_bank.part.0>:
  fa:	0a 12       	push	r10		;
  fc:	09 12       	push	r9		;
  fe:	08 12       	push	r8		;
 100:	08 4c       	mov	r12,	r8	;
 102:	49 4d       	mov.b	r13,	r9	;
 104:	3a 40 ba 07 	mov	#1978,	r10	;#0x07ba
 108:	5e 43       	mov.b	#1,	r14	;r3 As==01
 10a:	7d 40 18 00 	mov.b	#24,	r13	;#0x0018
 10e:	4c 4e       	mov.b	r14,	r12	;
 110:	8a 12       	call	r10		;
 112:	4e 43       	clr.b	r14		;
 114:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 118:	5c 43       	mov.b	#1,	r12	;r3 As==01
 11a:	8a 12       	call	r10		;
 11c:	4e 43       	clr.b	r14		;
 11e:	7d 40 1b 00 	mov.b	#27,	r13	;#0x001b
 122:	5c 43       	mov.b	#1,	r12	;r3 As==01
 124:	8a 12       	call	r10		;
 126:	4e 43       	clr.b	r14		;
 128:	7d 40 16 00 	mov.b	#22,	r13	;#0x0016
 12c:	5c 43       	mov.b	#1,	r12	;r3 As==01
 12e:	8a 12       	call	r10		;
 130:	5e 43       	mov.b	#1,	r14	;r3 As==01
 132:	7d 40 17 00 	mov.b	#23,	r13	;#0x0017
 136:	4c 4e       	mov.b	r14,	r12	;
 138:	8a 12       	call	r10		;
 13a:	5e 43       	mov.b	#1,	r14	;r3 As==01
 13c:	7d 40 1a 00 	mov.b	#26,	r13	;#0x001a
 140:	4c 4e       	mov.b	r14,	r12	;
 142:	8a 12       	call	r10		;
 144:	0e 48       	mov	r8,	r14	;
 146:	7d 40 11 00 	mov.b	#17,	r13	;#0x0011
 14a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 14c:	8a 12       	call	r10		;
 14e:	0e 49       	mov	r9,	r14	;
 150:	7d 40 14 00 	mov.b	#20,	r13	;#0x0014
 154:	5c 43       	mov.b	#1,	r12	;r3 As==01
 156:	8a 12       	call	r10		;
 158:	5e 43       	mov.b	#1,	r14	;r3 As==01
 15a:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 15e:	4c 4e       	mov.b	r14,	r12	;
 160:	8a 12       	call	r10		;
 162:	4e 43       	clr.b	r14		;
 164:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 168:	5c 43       	mov.b	#1,	r12	;r3 As==01
 16a:	8a 12       	call	r10		;
 16c:	b0 12 6c 00 	call	#108		;#0x006c
 170:	30 40 30 0c 	br	#0x0c30		;

00000174 <sdram_precharge>:
 174:	0a 12       	push	r10		;
 176:	3a 40 ba 07 	mov	#1978,	r10	;#0x07ba
 17a:	5e 43       	mov.b	#1,	r14	;r3 As==01
 17c:	7d 40 18 00 	mov.b	#24,	r13	;#0x0018
 180:	4c 4e       	mov.b	r14,	r12	;
 182:	8a 12       	call	r10		;
 184:	4e 43       	clr.b	r14		;
 186:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 18a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 18c:	8a 12       	call	r10		;
 18e:	5e 43       	mov.b	#1,	r14	;r3 As==01
 190:	7d 40 1b 00 	mov.b	#27,	r13	;#0x001b
 194:	4c 4e       	mov.b	r14,	r12	;
 196:	8a 12       	call	r10		;
 198:	4e 43       	clr.b	r14		;
 19a:	7d 40 16 00 	mov.b	#22,	r13	;#0x0016
 19e:	5c 43       	mov.b	#1,	r12	;r3 As==01
 1a0:	8a 12       	call	r10		;
 1a2:	5e 43       	mov.b	#1,	r14	;r3 As==01
 1a4:	7d 40 17 00 	mov.b	#23,	r13	;#0x0017
 1a8:	4c 4e       	mov.b	r14,	r12	;
 1aa:	8a 12       	call	r10		;
 1ac:	4e 43       	clr.b	r14		;
 1ae:	7d 40 1a 00 	mov.b	#26,	r13	;#0x001a
 1b2:	5c 43       	mov.b	#1,	r12	;r3 As==01
 1b4:	8a 12       	call	r10		;
 1b6:	3e 40 00 04 	mov	#1024,	r14	;#0x0400
 1ba:	7d 40 11 00 	mov.b	#17,	r13	;#0x0011
 1be:	5c 43       	mov.b	#1,	r12	;r3 As==01
 1c0:	8a 12       	call	r10		;
 1c2:	7e 40 03 00 	mov.b	#3,	r14	;
 1c6:	7d 40 14 00 	mov.b	#20,	r13	;#0x0014
 1ca:	5c 43       	mov.b	#1,	r12	;r3 As==01
 1cc:	8a 12       	call	r10		;
 1ce:	4e 43       	clr.b	r14		;
 1d0:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 1d4:	5c 43       	mov.b	#1,	r12	;r3 As==01
 1d6:	8a 12       	call	r10		;
 1d8:	5e 43       	mov.b	#1,	r14	;r3 As==01
 1da:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 1de:	4c 4e       	mov.b	r14,	r12	;
 1e0:	8a 12       	call	r10		;
 1e2:	4e 43       	clr.b	r14		;
 1e4:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 1e8:	5c 43       	mov.b	#1,	r12	;r3 As==01
 1ea:	8a 12       	call	r10		;
 1ec:	3a 41       	pop	r10		;
 1ee:	30 41       	ret			

000001f0 <sdram_write_single.part.1>:
 1f0:	0a 12       	push	r10		;
 1f2:	09 12       	push	r9		;
 1f4:	08 12       	push	r8		;
 1f6:	07 12       	push	r7		;
 1f8:	21 82       	sub	#4,	r1	;r2 As==10
 1fa:	08 4c       	mov	r12,	r8	;
 1fc:	47 4e       	mov.b	r14,	r7	;
 1fe:	09 4d       	mov	r13,	r9	;
 200:	09 5d       	add	r13,	r9	;
 202:	39 f0 00 08 	and	#2048,	r9	;#0x0800
 206:	3d f0 ff 03 	and	#1023,	r13	;#0x03ff
 20a:	09 dd       	bis	r13,	r9	;
 20c:	81 49 02 00 	mov	r9,	2(r1)	;
 210:	b1 40 a0 0c 	mov	#3232,	0(r1)	;#0x0ca0
 214:	00 00 
 216:	b0 12 ae 07 	call	#1966		;#0x07ae
 21a:	3a 40 ba 07 	mov	#1978,	r10	;#0x07ba
 21e:	5e 43       	mov.b	#1,	r14	;r3 As==01
 220:	7d 40 18 00 	mov.b	#24,	r13	;#0x0018
 224:	4c 4e       	mov.b	r14,	r12	;
 226:	8a 12       	call	r10		;
 228:	4e 43       	clr.b	r14		;
 22a:	7d 40 15 00 	mov.b	#21,	r13	;#0x0015
 22e:	5c 43       	mov.b	#1,	r12	;r3 As==01
 230:	8a 12       	call	r10		;
 232:	4e 43       	clr.b	r14		;
 234:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 238:	5c 43       	mov.b	#1,	r12	;r3 As==01
 23a:	8a 12       	call	r10		;
 23c:	4e 43       	clr.b	r14		;
 23e:	7d 40 1b 00 	mov.b	#27,	r13	;#0x001b
 242:	5c 43       	mov.b	#1,	r12	;r3 As==01
 244:	8a 12       	call	r10		;
 246:	5e 43       	mov.b	#1,	r14	;r3 As==01
 248:	7d 40 16 00 	mov.b	#22,	r13	;#0x0016
 24c:	4c 4e       	mov.b	r14,	r12	;
 24e:	8a 12       	call	r10		;
 250:	4e 43       	clr.b	r14		;
 252:	7d 40 17 00 	mov.b	#23,	r13	;#0x0017
 256:	5c 43       	mov.b	#1,	r12	;r3 As==01
 258:	8a 12       	call	r10		;
 25a:	4e 43       	clr.b	r14		;
 25c:	7d 40 1a 00 	mov.b	#26,	r13	;#0x001a
 260:	5c 43       	mov.b	#1,	r12	;r3 As==01
 262:	8a 12       	call	r10		;
 264:	0e 49       	mov	r9,	r14	;
 266:	7d 40 11 00 	mov.b	#17,	r13	;#0x0011
 26a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 26c:	8a 12       	call	r10		;
 26e:	0e 47       	mov	r7,	r14	;
 270:	7d 40 14 00 	mov.b	#20,	r13	;#0x0014
 274:	5c 43       	mov.b	#1,	r12	;r3 As==01
 276:	8a 12       	call	r10		;
 278:	0e 48       	mov	r8,	r14	;
 27a:	7d 40 12 00 	mov.b	#18,	r13	;#0x0012
 27e:	5c 43       	mov.b	#1,	r12	;r3 As==01
 280:	8a 12       	call	r10		;
 282:	5e 43       	mov.b	#1,	r14	;r3 As==01
 284:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 288:	4c 4e       	mov.b	r14,	r12	;
 28a:	8a 12       	call	r10		;
 28c:	4e 43       	clr.b	r14		;
 28e:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 292:	5c 43       	mov.b	#1,	r12	;r3 As==01
 294:	8a 12       	call	r10		;
 296:	b0 12 74 01 	call	#372		;#0x0174
 29a:	b0 12 6c 00 	call	#108		;#0x006c
 29e:	21 52       	add	#4,	r1	;r2 As==10
 2a0:	30 40 2e 0c 	br	#0x0c2e		;

000002a4 <sdram_read_single.part.2>:
 2a4:	0a 12       	push	r10		;
 2a6:	09 12       	push	r9		;
 2a8:	08 12       	push	r8		;
 2aa:	31 80 06 00 	sub	#6,	r1	;
 2ae:	48 4d       	mov.b	r13,	r8	;
 2b0:	09 4c       	mov	r12,	r9	;
 2b2:	09 5c       	add	r12,	r9	;
 2b4:	39 f0 00 08 	and	#2048,	r9	;#0x0800
 2b8:	3c f0 ff 03 	and	#1023,	r12	;#0x03ff
 2bc:	09 dc       	bis	r12,	r9	;
 2be:	81 49 02 00 	mov	r9,	2(r1)	;
 2c2:	b1 40 b1 0c 	mov	#3249,	0(r1)	;#0x0cb1
 2c6:	00 00 
 2c8:	b0 12 ae 07 	call	#1966		;#0x07ae
 2cc:	3a 40 ba 07 	mov	#1978,	r10	;#0x07ba
 2d0:	5e 43       	mov.b	#1,	r14	;r3 As==01
 2d2:	7d 40 18 00 	mov.b	#24,	r13	;#0x0018
 2d6:	4c 4e       	mov.b	r14,	r12	;
 2d8:	8a 12       	call	r10		;
 2da:	4e 43       	clr.b	r14		;
 2dc:	7d 40 15 00 	mov.b	#21,	r13	;#0x0015
 2e0:	5c 43       	mov.b	#1,	r12	;r3 As==01
 2e2:	8a 12       	call	r10		;
 2e4:	4e 43       	clr.b	r14		;
 2e6:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 2ea:	5c 43       	mov.b	#1,	r12	;r3 As==01
 2ec:	8a 12       	call	r10		;
 2ee:	4e 43       	clr.b	r14		;
 2f0:	7d 40 1b 00 	mov.b	#27,	r13	;#0x001b
 2f4:	5c 43       	mov.b	#1,	r12	;r3 As==01
 2f6:	8a 12       	call	r10		;
 2f8:	5e 43       	mov.b	#1,	r14	;r3 As==01
 2fa:	7d 40 16 00 	mov.b	#22,	r13	;#0x0016
 2fe:	4c 4e       	mov.b	r14,	r12	;
 300:	8a 12       	call	r10		;
 302:	4e 43       	clr.b	r14		;
 304:	7d 40 17 00 	mov.b	#23,	r13	;#0x0017
 308:	5c 43       	mov.b	#1,	r12	;r3 As==01
 30a:	8a 12       	call	r10		;
 30c:	5e 43       	mov.b	#1,	r14	;r3 As==01
 30e:	7d 40 1a 00 	mov.b	#26,	r13	;#0x001a
 312:	4c 4e       	mov.b	r14,	r12	;
 314:	8a 12       	call	r10		;
 316:	0e 49       	mov	r9,	r14	;
 318:	7d 40 11 00 	mov.b	#17,	r13	;#0x0011
 31c:	5c 43       	mov.b	#1,	r12	;r3 As==01
 31e:	8a 12       	call	r10		;
 320:	0e 48       	mov	r8,	r14	;
 322:	7d 40 14 00 	mov.b	#20,	r13	;#0x0014
 326:	5c 43       	mov.b	#1,	r12	;r3 As==01
 328:	8a 12       	call	r10		;
 32a:	5e 43       	mov.b	#1,	r14	;r3 As==01
 32c:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 330:	4c 4e       	mov.b	r14,	r12	;
 332:	8a 12       	call	r10		;
 334:	4e 43       	clr.b	r14		;
 336:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 33a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 33c:	8a 12       	call	r10		;
 33e:	5e 43       	mov.b	#1,	r14	;r3 As==01
 340:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 344:	4c 4e       	mov.b	r14,	r12	;
 346:	8a 12       	call	r10		;
 348:	4e 43       	clr.b	r14		;
 34a:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 34e:	5c 43       	mov.b	#1,	r12	;r3 As==01
 350:	8a 12       	call	r10		;
 352:	4e 43       	clr.b	r14		;
 354:	7d 40 13 00 	mov.b	#19,	r13	;#0x0013
 358:	4c 4e       	mov.b	r14,	r12	;
 35a:	8a 12       	call	r10		;
 35c:	81 4c 04 00 	mov	r12,	4(r1)	;
 360:	b0 12 74 01 	call	#372		;#0x0174
 364:	b0 12 6c 00 	call	#108		;#0x006c
 368:	1c 41 04 00 	mov	4(r1),	r12	;
 36c:	31 50 06 00 	add	#6,	r1	;
 370:	30 40 30 0c 	br	#0x0c30		;

00000374 <main>:
 374:	0a 12       	push	r10		;
 376:	09 12       	push	r9		;
 378:	08 12       	push	r8		;
 37a:	07 12       	push	r7		;
 37c:	06 12       	push	r6		;
 37e:	05 12       	push	r5		;
 380:	04 12       	push	r4		;
 382:	21 82       	sub	#4,	r1	;r2 As==10
 384:	4c 43       	clr.b	r12		;
 386:	b0 12 8a 0a 	call	#2698		;#0x0a8a
 38a:	6c 43       	mov.b	#2,	r12	;r3 As==10
 38c:	b0 12 52 0a 	call	#2642		;#0x0a52
 390:	3c 40 00 4b 	mov	#19200,	r12	;#0x4b00
 394:	4d 43       	clr.b	r13		;
 396:	b0 12 14 0b 	call	#2836		;#0x0b14
 39a:	b1 40 55 0d 	mov	#3413,	0(r1)	;#0x0d55
 39e:	00 00 
 3a0:	3a 40 ae 07 	mov	#1966,	r10	;#0x07ae
 3a4:	8a 12       	call	r10		;
 3a6:	b1 40 76 0d 	mov	#3446,	0(r1)	;#0x0d76
 3aa:	00 00 
 3ac:	8a 12       	call	r10		;
 3ae:	6c 43       	mov.b	#2,	r12	;r3 As==10
 3b0:	b0 12 b2 0a 	call	#2738		;#0x0ab2
 3b4:	b0 12 f6 0a 	call	#2806		;#0x0af6
 3b8:	38 40 6e 0a 	mov	#2670,	r8	;#0x0a6e
 3bc:	4c 43       	clr.b	r12		;
 3be:	88 12       	call	r8		;
 3c0:	39 40 26 0a 	mov	#2598,	r9	;#0x0a26
 3c4:	7c 40 96 00 	mov.b	#150,	r12	;#0x0096
 3c8:	89 12       	call	r9		;
 3ca:	6c 43       	mov.b	#2,	r12	;r3 As==10
 3cc:	88 12       	call	r8		;
 3ce:	38 40 ba 07 	mov	#1978,	r8	;#0x07ba
 3d2:	3e 43       	mov	#-1,	r14	;r3 As==11
 3d4:	4d 43       	clr.b	r13		;
 3d6:	5c 43       	mov.b	#1,	r12	;r3 As==01
 3d8:	88 12       	call	r8		;
 3da:	b0 12 6c 00 	call	#108		;#0x006c
 3de:	37 40 fa 00 	mov	#250,	r7	;#0x00fa
 3e2:	4d 43       	clr.b	r13		;
 3e4:	4c 43       	clr.b	r12		;
 3e6:	87 12       	call	r7		;
 3e8:	36 40 f0 01 	mov	#496,	r6	;#0x01f0
 3ec:	4e 43       	clr.b	r14		;
 3ee:	4d 43       	clr.b	r13		;
 3f0:	3c 40 ef be 	mov	#-16657,r12	;#0xbeef
 3f4:	86 12       	call	r6		;
 3f6:	4e 43       	clr.b	r14		;
 3f8:	6d 43       	mov.b	#2,	r13	;r3 As==10
 3fa:	3c 40 ad de 	mov	#-8531,	r12	;#0xdead
 3fe:	86 12       	call	r6		;
 400:	4e 43       	clr.b	r14		;
 402:	7d 40 12 00 	mov.b	#18,	r13	;#0x0012
 406:	5c 43       	mov.b	#1,	r12	;r3 As==01
 408:	88 12       	call	r8		;
 40a:	3c 40 e8 03 	mov	#1000,	r12	;#0x03e8
 40e:	89 12       	call	r9		;
 410:	4d 43       	clr.b	r13		;
 412:	4c 43       	clr.b	r12		;
 414:	87 12       	call	r7		;
 416:	37 40 a4 02 	mov	#676,	r7	;#0x02a4
 41a:	4d 43       	clr.b	r13		;
 41c:	4c 43       	clr.b	r12		;
 41e:	87 12       	call	r7		;
 420:	06 4c       	mov	r12,	r6	;
 422:	4e 43       	clr.b	r14		;
 424:	7d 40 12 00 	mov.b	#18,	r13	;#0x0012
 428:	5c 43       	mov.b	#1,	r12	;r3 As==01
 42a:	88 12       	call	r8		;
 42c:	4e 43       	clr.b	r14		;
 42e:	7d 40 12 00 	mov.b	#18,	r13	;#0x0012
 432:	4c 4e       	mov.b	r14,	r12	;
 434:	88 12       	call	r8		;
 436:	81 4c 02 00 	mov	r12,	2(r1)	;
 43a:	b1 40 84 0d 	mov	#3460,	0(r1)	;#0x0d84
 43e:	00 00 
 440:	8a 12       	call	r10		;
 442:	81 46 02 00 	mov	r6,	2(r1)	;
 446:	b1 40 93 0d 	mov	#3475,	0(r1)	;#0x0d93
 44a:	00 00 
 44c:	8a 12       	call	r10		;
 44e:	48 43       	clr.b	r8		;
 450:	44 48       	mov.b	r8,	r4	;
 452:	35 40 20 0c 	mov	#3104,	r5	;#0x0c20
 456:	36 40 36 08 	mov	#2102,	r6	;#0x0836

0000045a <.L22>:
 45a:	4d 44       	mov.b	r4,	r13	;
 45c:	6c 43       	mov.b	#2,	r12	;r3 As==10
 45e:	87 12       	call	r7		;
 460:	81 4c 02 00 	mov	r12,	2(r1)	;
 464:	b1 40 93 0d 	mov	#3475,	0(r1)	;#0x0d93
 468:	00 00 
 46a:	8a 12       	call	r10		;
 46c:	3d 40 10 27 	mov	#10000,	r13	;#0x2710
 470:	0c 48       	mov	r8,	r12	;
 472:	85 12       	call	r5		;
 474:	0d 4c       	mov	r12,	r13	;
 476:	5c 43       	mov.b	#1,	r12	;r3 As==01
 478:	86 12       	call	r6		;
 47a:	3c 40 d0 07 	mov	#2000,	r12	;#0x07d0
 47e:	89 12       	call	r9		;
 480:	28 53       	incd	r8		;
 482:	30 40 5a 04 	br	#0x045a		;

00000486 <printchar>:
 486:	3d f0 ff 00 	and	#255,	r13	;#0x00ff
 48a:	0c 93       	cmp	#0,	r12	;r3 As==00
 48c:	06 24       	jz	$+14     	;abs 0x49a
 48e:	2e 4c       	mov	@r12,	r14	;
 490:	ce 4d 00 00 	mov.b	r13,	0(r14)	;
 494:	9c 53 00 00 	inc	0(r12)		;

00000498 <.L2>:
 498:	30 41       	ret			

0000049a <.L3>:
 49a:	4c 4d       	mov.b	r13,	r12	;
 49c:	b0 12 94 0b 	call	#2964		;#0x0b94
 4a0:	30 40 98 04 	br	#0x0498		;

000004a4 <prints>:
 4a4:	0a 12       	push	r10		;
 4a6:	09 12       	push	r9		;
 4a8:	08 12       	push	r8		;
 4aa:	07 12       	push	r7		;
 4ac:	06 12       	push	r6		;
 4ae:	05 12       	push	r5		;
 4b0:	04 12       	push	r4		;
 4b2:	06 4c       	mov	r12,	r6	;
 4b4:	05 4d       	mov	r13,	r5	;
 4b6:	0a 4e       	mov	r14,	r10	;
 4b8:	4c 43       	clr.b	r12		;
 4ba:	0c 9e       	cmp	r14,	r12	;
 4bc:	19 38       	jl	$+52     	;abs 0x4f0

000004be <.L21>:
 4be:	77 40 20 00 	mov.b	#32,	r7	;#0x0020
 4c2:	30 40 e0 04 	br	#0x04e0		;

000004c6 <.L8>:
 4c6:	1c 53       	inc	r12		;

000004c8 <.L6>:
 4c8:	0d 45       	mov	r5,	r13	;
 4ca:	0d 5c       	add	r12,	r13	;
 4cc:	cd 93 00 00 	cmp.b	#0,	0(r13)	;r3 As==00
 4d0:	fa 23       	jnz	$-10     	;abs 0x4c6
 4d2:	0c 9a       	cmp	r10,	r12	;
 4d4:	10 34       	jge	$+34     	;abs 0x4f6
 4d6:	0a 8c       	sub	r12,	r10	;

000004d8 <.L9>:
 4d8:	2f b3       	bit	#2,	r15	;r3 As==10
 4da:	f1 27       	jz	$-28     	;abs 0x4be
 4dc:	77 40 30 00 	mov.b	#48,	r7	;#0x0030

000004e0 <.L7>:
 4e0:	1f b3       	bit	#1,	r15	;r3 As==01
 4e2:	1a 24       	jz	$+54     	;abs 0x518
 4e4:	49 43       	clr.b	r9		;

000004e6 <.L11>:
 4e6:	08 49       	mov	r9,	r8	;
 4e8:	34 40 86 04 	mov	#1158,	r4	;#0x0486
 4ec:	30 40 28 05 	br	#0x0528		;

000004f0 <.L19>:
 4f0:	4c 43       	clr.b	r12		;
 4f2:	30 40 c8 04 	br	#0x04c8		;

000004f6 <.L20>:
 4f6:	4a 43       	clr.b	r10		;
 4f8:	30 40 d8 04 	br	#0x04d8		;

000004fc <.L12>:
 4fc:	0d 47       	mov	r7,	r13	;
 4fe:	0c 46       	mov	r6,	r12	;
 500:	88 12       	call	r8		;
 502:	39 53       	add	#-1,	r9	;r3 As==11

00000504 <.L10>:
 504:	4c 43       	clr.b	r12		;
 506:	0c 99       	cmp	r9,	r12	;
 508:	f9 3b       	jl	$-12     	;abs 0x4fc
 50a:	09 4a       	mov	r10,	r9	;
 50c:	0a 9c       	cmp	r12,	r10	;
 50e:	01 34       	jge	$+4      	;abs 0x512
 510:	09 4c       	mov	r12,	r9	;

00000512 <.L13>:
 512:	0a 89       	sub	r9,	r10	;
 514:	30 40 e6 04 	br	#0x04e6		;

00000518 <.L22>:
 518:	09 4a       	mov	r10,	r9	;
 51a:	38 40 86 04 	mov	#1158,	r8	;#0x0486
 51e:	30 40 04 05 	br	#0x0504		;

00000522 <.L15>:
 522:	0c 46       	mov	r6,	r12	;
 524:	84 12       	call	r4		;
 526:	18 53       	inc	r8		;

00000528 <.L14>:
 528:	0c 48       	mov	r8,	r12	;
 52a:	0c 89       	sub	r9,	r12	;
 52c:	0c 55       	add	r5,	r12	;
 52e:	6d 4c       	mov.b	@r12,	r13	;
 530:	0d 93       	cmp	#0,	r13	;r3 As==00
 532:	f7 23       	jnz	$-16     	;abs 0x522
 534:	09 4a       	mov	r10,	r9	;
 536:	35 40 86 04 	mov	#1158,	r5	;#0x0486

0000053a <.L16>:
 53a:	4c 43       	clr.b	r12		;
 53c:	0c 99       	cmp	r9,	r12	;
 53e:	07 38       	jl	$+16     	;abs 0x54e
 540:	0c 4a       	mov	r10,	r12	;
 542:	0a 93       	cmp	#0,	r10	;r3 As==00
 544:	01 34       	jge	$+4      	;abs 0x548
 546:	4c 43       	clr.b	r12		;

00000548 <.L18>:
 548:	0c 58       	add	r8,	r12	;
 54a:	30 40 28 0c 	br	#0x0c28		;

0000054e <.L17>:
 54e:	0d 47       	mov	r7,	r13	;
 550:	0c 46       	mov	r6,	r12	;
 552:	85 12       	call	r5		;
 554:	39 53       	add	#-1,	r9	;r3 As==11
 556:	30 40 3a 05 	br	#0x053a		;

0000055a <printi>:
 55a:	0a 12       	push	r10		;
 55c:	09 12       	push	r9		;
 55e:	08 12       	push	r8		;
 560:	07 12       	push	r7		;
 562:	06 12       	push	r6		;
 564:	05 12       	push	r5		;
 566:	04 12       	push	r4		;
 568:	31 80 0e 00 	sub	#14,	r1	;#0x000e
 56c:	07 4c       	mov	r12,	r7	;
 56e:	05 4e       	mov	r14,	r5	;
 570:	0a 4f       	mov	r15,	r10	;
 572:	19 41 1e 00 	mov	30(r1),	r9	;0x0001e
 576:	06 4d       	mov	r13,	r6	;
 578:	0d 93       	cmp	#0,	r13	;r3 As==00
 57a:	10 20       	jnz	$+34     	;abs 0x59c
 57c:	f1 40 30 00 	mov.b	#48,	2(r1)	;#0x0030
 580:	02 00 
 582:	c1 4d 03 00 	mov.b	r13,	3(r1)	;
 586:	1f 41 20 00 	mov	32(r1),	r15	;0x00020
 58a:	0e 49       	mov	r9,	r14	;
 58c:	0d 41       	mov	r1,	r13	;
 58e:	2d 53       	incd	r13		;
 590:	b0 12 a4 04 	call	#1188		;#0x04a4

00000594 <.L23>:
 594:	31 50 0e 00 	add	#14,	r1	;#0x000e
 598:	30 40 28 0c 	br	#0x0c28		;

0000059c <.L24>:
 59c:	0f 93       	cmp	#0,	r15	;r3 As==00
 59e:	09 24       	jz	$+20     	;abs 0x5b2
 5a0:	3e 90 0a 00 	cmp	#10,	r14	;#0x000a
 5a4:	3d 20       	jnz	$+124    	;abs 0x620
 5a6:	0d 93       	cmp	#0,	r13	;r3 As==00
 5a8:	3b 34       	jge	$+120    	;abs 0x620
 5aa:	4c 43       	clr.b	r12		;
 5ac:	0c 8d       	sub	r13,	r12	;
 5ae:	06 4c       	mov	r12,	r6	;
 5b0:	5a 43       	mov.b	#1,	r10	;r3 As==01

000005b2 <.L26>:
 5b2:	c1 43 0d 00 	mov.b	#0,	13(r1)	;r3 As==00, 0x000d
 5b6:	08 41       	mov	r1,	r8	;
 5b8:	38 50 0d 00 	add	#13,	r8	;#0x000d
 5bc:	1d 41 22 00 	mov	34(r1),	r13	;0x00022
 5c0:	3d 50 c6 ff 	add	#-58,	r13	;#0xffc6
 5c4:	81 4d 00 00 	mov	r13,	0(r1)	;

000005c8 <.L28>:
 5c8:	0d 45       	mov	r5,	r13	;
 5ca:	0c 46       	mov	r6,	r12	;
 5cc:	b0 12 20 0c 	call	#3104		;#0x0c20
 5d0:	7d 40 09 00 	mov.b	#9,	r13	;
 5d4:	0d 9c       	cmp	r12,	r13	;
 5d6:	01 34       	jge	$+4      	;abs 0x5da
 5d8:	2c 51       	add	@r1,	r12	;

000005da <.L27>:
 5da:	04 48       	mov	r8,	r4	;
 5dc:	34 53       	add	#-1,	r4	;r3 As==11
 5de:	7c 50 30 00 	add.b	#48,	r12	;#0x0030
 5e2:	c4 4c 00 00 	mov.b	r12,	0(r4)	;
 5e6:	0d 45       	mov	r5,	r13	;
 5e8:	0c 46       	mov	r6,	r12	;
 5ea:	b0 12 18 0c 	call	#3096		;#0x0c18
 5ee:	06 95       	cmp	r5,	r6	;
 5f0:	1a 2c       	jc	$+54     	;abs 0x626
 5f2:	0a 93       	cmp	#0,	r10	;r3 As==00
 5f4:	0b 24       	jz	$+24     	;abs 0x60c
 5f6:	09 93       	cmp	#0,	r9	;r3 As==00
 5f8:	1a 24       	jz	$+54     	;abs 0x62e
 5fa:	a1 b3 20 00 	bit	#2,	32(r1)	;r3 As==10, 0x0020
 5fe:	17 24       	jz	$+48     	;abs 0x62e
 600:	7d 40 2d 00 	mov.b	#45,	r13	;#0x002d
 604:	0c 47       	mov	r7,	r12	;
 606:	b0 12 86 04 	call	#1158		;#0x0486
 60a:	39 53       	add	#-1,	r9	;r3 As==11

0000060c <.L29>:
 60c:	1f 41 20 00 	mov	32(r1),	r15	;0x00020
 610:	0e 49       	mov	r9,	r14	;
 612:	0d 44       	mov	r4,	r13	;
 614:	0c 47       	mov	r7,	r12	;
 616:	b0 12 a4 04 	call	#1188		;#0x04a4
 61a:	0c 5a       	add	r10,	r12	;
 61c:	30 40 94 05 	br	#0x0594		;

00000620 <.L32>:
 620:	4a 43       	clr.b	r10		;
 622:	30 40 b2 05 	br	#0x05b2		;

00000626 <.L33>:
 626:	06 4c       	mov	r12,	r6	;
 628:	08 44       	mov	r4,	r8	;
 62a:	30 40 c8 05 	br	#0x05c8		;

0000062e <.L30>:
 62e:	f4 40 2d 00 	mov.b	#45,	-1(r4)	;#0x002d, 0xffff
 632:	ff ff 
 634:	04 48       	mov	r8,	r4	;
 636:	34 50 fe ff 	add	#-2,	r4	;#0xfffe
 63a:	4a 43       	clr.b	r10		;
 63c:	30 40 0c 06 	br	#0x060c		;

00000640 <print>:
 640:	0a 12       	push	r10		;
 642:	09 12       	push	r9		;
 644:	08 12       	push	r8		;
 646:	07 12       	push	r7		;
 648:	06 12       	push	r6		;
 64a:	05 12       	push	r5		;
 64c:	04 12       	push	r4		;
 64e:	31 82       	sub	#8,	r1	;r2 As==11
 650:	07 4c       	mov	r12,	r7	;
 652:	0a 4d       	mov	r13,	r10	;
 654:	2a 53       	incd	r10		;
 656:	28 4d       	mov	@r13,	r8	;
 658:	49 43       	clr.b	r9		;
 65a:	35 40 86 04 	mov	#1158,	r5	;#0x0486
 65e:	06 49       	mov	r9,	r6	;

00000660 <.L47>:
 660:	6c 48       	mov.b	@r8,	r12	;
 662:	0c 93       	cmp	#0,	r12	;r3 As==00
 664:	09 20       	jnz	$+20     	;abs 0x678

00000666 <.L49>:
 666:	07 93       	cmp	#0,	r7	;r3 As==00
 668:	03 24       	jz	$+8      	;abs 0x670
 66a:	2c 47       	mov	@r7,	r12	;
 66c:	cc 43 00 00 	mov.b	#0,	0(r12)	;r3 As==00

00000670 <.L46>:
 670:	0c 49       	mov	r9,	r12	;
 672:	31 52       	add	#8,	r1	;r2 As==11
 674:	30 40 28 0c 	br	#0x0c28		;

00000678 <.L62>:
 678:	3c 90 25 00 	cmp	#37,	r12	;#0x0025
 67c:	92 20       	jnz	$+294    	;abs 0x7a2
 67e:	5c 48 01 00 	mov.b	1(r8),	r12	;
 682:	0c 93       	cmp	#0,	r12	;r3 As==00
 684:	f0 27       	jz	$-30     	;abs 0x666
 686:	0d 48       	mov	r8,	r13	;
 688:	1d 53       	inc	r13		;
 68a:	7c 90 25 00 	cmp.b	#37,	r12	;#0x0025
 68e:	88 24       	jz	$+274    	;abs 0x7a0
 690:	7c 90 2d 00 	cmp.b	#45,	r12	;#0x002d
 694:	23 20       	jnz	$+72     	;abs 0x6dc
 696:	1d 53       	inc	r13		;
 698:	5f 43       	mov.b	#1,	r15	;r3 As==01

0000069a <.L50>:
 69a:	08 4d       	mov	r13,	r8	;

0000069c <.L51>:
 69c:	0c 48       	mov	r8,	r12	;
 69e:	1c 53       	inc	r12		;
 6a0:	f8 90 30 00 	cmp.b	#48,	0(r8)	;#0x0030
 6a4:	00 00 
 6a6:	1d 24       	jz	$+60     	;abs 0x6e2
 6a8:	0e 46       	mov	r6,	r14	;

000006aa <.L53>:
 6aa:	6c 48       	mov.b	@r8,	r12	;
 6ac:	04 48       	mov	r8,	r4	;
 6ae:	14 53       	inc	r4		;
 6b0:	4d 4c       	mov.b	r12,	r13	;
 6b2:	7d 50 d0 ff 	add.b	#-48,	r13	;#0xffd0
 6b6:	7b 40 09 00 	mov.b	#9,	r11	;
 6ba:	4b 9d       	cmp.b	r13,	r11	;
 6bc:	16 2c       	jc	$+46     	;abs 0x6ea
 6be:	7c 90 73 00 	cmp.b	#115,	r12	;#0x0073
 6c2:	1e 20       	jnz	$+62     	;abs 0x700
 6c4:	04 4a       	mov	r10,	r4	;
 6c6:	24 53       	incd	r4		;
 6c8:	2d 4a       	mov	@r10,	r13	;
 6ca:	0d 93       	cmp	#0,	r13	;r3 As==00
 6cc:	02 20       	jnz	$+6      	;abs 0x6d2
 6ce:	3d 40 ab 0d 	mov	#3499,	r13	;#0x0dab

000006d2 <.L76>:
 6d2:	0c 47       	mov	r7,	r12	;
 6d4:	b0 12 a4 04 	call	#1188		;#0x04a4
 6d8:	30 40 26 07 	br	#0x0726		;

000006dc <.L65>:
 6dc:	4f 43       	clr.b	r15		;
 6de:	30 40 9a 06 	br	#0x069a		;

000006e2 <.L52>:
 6e2:	2f d3       	bis	#2,	r15	;r3 As==10
 6e4:	08 4c       	mov	r12,	r8	;
 6e6:	30 40 9c 06 	br	#0x069c		;

000006ea <.L54>:
 6ea:	0d 4e       	mov	r14,	r13	;
 6ec:	0d 5e       	add	r14,	r13	;
 6ee:	0d 5d       	rla	r13		;
 6f0:	0e 5d       	add	r13,	r14	;
 6f2:	0e 5e       	rla	r14		;
 6f4:	3c 50 d0 ff 	add	#-48,	r12	;#0xffd0
 6f8:	0e 5c       	add	r12,	r14	;
 6fa:	08 44       	mov	r4,	r8	;
 6fc:	30 40 aa 06 	br	#0x06aa		;

00000700 <.L55>:
 700:	7c 90 64 00 	cmp.b	#100,	r12	;#0x0064
 704:	15 20       	jnz	$+44     	;abs 0x730
 706:	04 4a       	mov	r10,	r4	;
 708:	24 53       	incd	r4		;
 70a:	b1 40 61 00 	mov	#97,	4(r1)	;#0x0061
 70e:	04 00 
 710:	81 4f 02 00 	mov	r15,	2(r1)	;
 714:	81 4e 00 00 	mov	r14,	0(r1)	;
 718:	5f 43       	mov.b	#1,	r15	;r3 As==01

0000071a <.L74>:
 71a:	7e 40 0a 00 	mov.b	#10,	r14	;#0x000a

0000071e <.L73>:
 71e:	2d 4a       	mov	@r10,	r13	;
 720:	0c 47       	mov	r7,	r12	;
 722:	b0 12 5a 05 	call	#1370		;#0x055a

00000726 <.L72>:
 726:	09 5c       	add	r12,	r9	;
 728:	0a 44       	mov	r4,	r10	;

0000072a <.L57>:
 72a:	18 53       	inc	r8		;
 72c:	30 40 60 06 	br	#0x0660		;

00000730 <.L58>:
 730:	7c 90 78 00 	cmp.b	#120,	r12	;#0x0078
 734:	0e 20       	jnz	$+30     	;abs 0x752
 736:	04 4a       	mov	r10,	r4	;
 738:	24 53       	incd	r4		;
 73a:	b1 40 61 00 	mov	#97,	4(r1)	;#0x0061
 73e:	04 00 

00000740 <.L75>:
 740:	81 4f 02 00 	mov	r15,	2(r1)	;
 744:	81 4e 00 00 	mov	r14,	0(r1)	;
 748:	0f 46       	mov	r6,	r15	;
 74a:	7e 40 10 00 	mov.b	#16,	r14	;#0x0010
 74e:	30 40 1e 07 	br	#0x071e		;

00000752 <.L59>:
 752:	7c 90 58 00 	cmp.b	#88,	r12	;#0x0058
 756:	07 20       	jnz	$+16     	;abs 0x766
 758:	04 4a       	mov	r10,	r4	;
 75a:	24 53       	incd	r4		;
 75c:	b1 40 41 00 	mov	#65,	4(r1)	;#0x0041
 760:	04 00 
 762:	30 40 40 07 	br	#0x0740		;

00000766 <.L60>:
 766:	7c 90 75 00 	cmp.b	#117,	r12	;#0x0075
 76a:	0c 20       	jnz	$+26     	;abs 0x784
 76c:	04 4a       	mov	r10,	r4	;
 76e:	24 53       	incd	r4		;
 770:	b1 40 61 00 	mov	#97,	4(r1)	;#0x0061
 774:	04 00 
 776:	81 4f 02 00 	mov	r15,	2(r1)	;
 77a:	81 4e 00 00 	mov	r14,	0(r1)	;
 77e:	0f 46       	mov	r6,	r15	;
 780:	30 40 1a 07 	br	#0x071a		;

00000784 <.L61>:
 784:	7c 90 63 00 	cmp.b	#99,	r12	;#0x0063
 788:	d0 23       	jnz	$-94     	;abs 0x72a
 78a:	04 4a       	mov	r10,	r4	;
 78c:	24 53       	incd	r4		;
 78e:	e1 4a 06 00 	mov.b	@r10,	6(r1)	;
 792:	c1 43 07 00 	mov.b	#0,	7(r1)	;r3 As==00
 796:	0d 41       	mov	r1,	r13	;
 798:	3d 50 06 00 	add	#6,	r13	;
 79c:	30 40 d2 06 	br	#0x06d2		;

000007a0 <.L64>:
 7a0:	08 4d       	mov	r13,	r8	;

000007a2 <.L48>:
 7a2:	6d 48       	mov.b	@r8,	r13	;
 7a4:	0c 47       	mov	r7,	r12	;
 7a6:	85 12       	call	r5		;
 7a8:	19 53       	inc	r9		;
 7aa:	30 40 2a 07 	br	#0x072a		;

000007ae <hal_printf>:
 7ae:	0d 41       	mov	r1,	r13	;
 7b0:	2d 53       	incd	r13		;
 7b2:	4c 43       	clr.b	r12		;
 7b4:	b0 12 40 06 	call	#1600		;#0x0640
 7b8:	30 41       	ret			

000007ba <rw_registers>:
 7ba:	0a 12       	push	r10		;
 7bc:	09 12       	push	r9		;
 7be:	08 12       	push	r8		;
 7c0:	07 12       	push	r7		;
 7c2:	06 12       	push	r6		;
 7c4:	05 12       	push	r5		;
 7c6:	04 12       	push	r4		;
 7c8:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 7cc:	09 4d       	mov	r13,	r9	;
 7ce:	06 4e       	mov	r14,	r6	;
 7d0:	3a 40 52 0a 	mov	#2642,	r10	;#0x0a52
 7d4:	1c 93       	cmp	#1,	r12	;r3 As==01
 7d6:	2a 20       	jnz	$+86     	;abs 0x82c
 7d8:	8a 12       	call	r10		;

000007da <.L3>:
 7da:	4c 43       	clr.b	r12		;
 7dc:	8a 12       	call	r10		;
 7de:	37 40 da 0a 	mov	#2778,	r7	;#0x0ada
 7e2:	4c 43       	clr.b	r12		;
 7e4:	87 12       	call	r7		;
 7e6:	38 40 fe 0a 	mov	#2814,	r8	;#0x0afe
 7ea:	0c 49       	mov	r9,	r12	;
 7ec:	88 12       	call	r8		;
 7ee:	39 40 f6 0a 	mov	#2806,	r9	;#0x0af6
 7f2:	89 12       	call	r9		;
 7f4:	3a 40 51 c3 	mov	#-15535,r10	;#0xc351
 7f8:	35 40 90 0a 	mov	#2704,	r5	;#0x0a90
 7fc:	44 43       	clr.b	r4		;

000007fe <.L4>:
 7fe:	4c 44       	mov.b	r4,	r12	;
 800:	85 12       	call	r5		;
 802:	0c 93       	cmp	#0,	r12	;r3 As==00
 804:	07 20       	jnz	$+16     	;abs 0x814
 806:	3a 53       	add	#-1,	r10	;r3 As==11
 808:	0a 93       	cmp	#0,	r10	;r3 As==00
 80a:	f9 23       	jnz	$-12     	;abs 0x7fe
 80c:	3c 40 b2 0d 	mov	#3506,	r12	;#0x0db2
 810:	b0 12 a8 0b 	call	#2984		;#0x0ba8

00000814 <.L5>:
 814:	4c 43       	clr.b	r12		;
 816:	87 12       	call	r7		;
 818:	0c 46       	mov	r6,	r12	;
 81a:	88 12       	call	r8		;
 81c:	0a 4c       	mov	r12,	r10	;
 81e:	89 12       	call	r9		;
 820:	4c 43       	clr.b	r12		;
 822:	b0 12 6e 0a 	call	#2670		;#0x0a6e
 826:	0c 4a       	mov	r10,	r12	;
 828:	30 40 28 0c 	br	#0x0c28		;

0000082c <.L2>:
 82c:	5c 43       	mov.b	#1,	r12	;r3 As==01
 82e:	b0 12 6e 0a 	call	#2670		;#0x0a6e
 832:	30 40 da 07 	br	#0x07da		;

00000836 <write_dec_to_hex_segments>:
 836:	0a 12       	push	r10		;
 838:	09 12       	push	r9		;
 83a:	08 12       	push	r8		;
 83c:	07 12       	push	r7		;
 83e:	06 12       	push	r6		;
 840:	05 12       	push	r5		;
 842:	04 12       	push	r4		;
 844:	21 83       	decd	r1		;
 846:	49 4c       	mov.b	r12,	r9	;
 848:	0a 4d       	mov	r13,	r10	;
 84a:	7c 40 09 00 	mov.b	#9,	r12	;
 84e:	0c 9d       	cmp	r13,	r12	;
 850:	2a 28       	jnc	$+86     	;abs 0x8a6
 852:	38 40 ba 07 	mov	#1978,	r8	;#0x07ba
 856:	0e 4d       	mov	r13,	r14	;
 858:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 85c:	5c 43       	mov.b	#1,	r12	;r3 As==01
 85e:	88 12       	call	r8		;
 860:	3e 43       	mov	#-1,	r14	;r3 As==11
 862:	7d 40 0c 00 	mov.b	#12,	r13	;#0x000c
 866:	5c 43       	mov.b	#1,	r12	;r3 As==01
 868:	88 12       	call	r8		;
 86a:	3e 43       	mov	#-1,	r14	;r3 As==11
 86c:	7d 40 0d 00 	mov.b	#13,	r13	;#0x000d
 870:	5c 43       	mov.b	#1,	r12	;r3 As==01
 872:	88 12       	call	r8		;
 874:	3e 43       	mov	#-1,	r14	;r3 As==11
 876:	7d 40 0e 00 	mov.b	#14,	r13	;#0x000e
 87a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 87c:	88 12       	call	r8		;
 87e:	09 93       	cmp	#0,	r9	;r3 As==00
 880:	0a 20       	jnz	$+22     	;abs 0x896
 882:	3e 40 fe ff 	mov	#-2,	r14	;#0xfffe
 886:	7d 40 0b 00 	mov.b	#11,	r13	;#0x000b

0000088a <.L18>:
 88a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 88c:	88 12       	call	r8		;

0000088e <.L8>:
 88e:	0c 49       	mov	r9,	r12	;
 890:	21 53       	incd	r1		;
 892:	30 40 28 0c 	br	#0x0c28		;

00000896 <.L10>:
 896:	3e 43       	mov	#-1,	r14	;r3 As==11
 898:	7d 40 0b 00 	mov.b	#11,	r13	;#0x000b

0000089c <.L19>:
 89c:	5c 43       	mov.b	#1,	r12	;r3 As==01
 89e:	88 12       	call	r8		;
 8a0:	49 43       	clr.b	r9		;
 8a2:	30 40 8e 08 	br	#0x088e		;

000008a6 <.L9>:
 8a6:	7c 40 63 00 	mov.b	#99,	r12	;#0x0063
 8aa:	0c 9d       	cmp	r13,	r12	;
 8ac:	2f 28       	jnc	$+96     	;abs 0x90c
 8ae:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 8b2:	0c 4a       	mov	r10,	r12	;
 8b4:	b0 12 20 0c 	call	#3104		;#0x0c20
 8b8:	07 4c       	mov	r12,	r7	;
 8ba:	38 40 ba 07 	mov	#1978,	r8	;#0x07ba
 8be:	0e 4c       	mov	r12,	r14	;
 8c0:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 8c4:	5c 43       	mov.b	#1,	r12	;r3 As==01
 8c6:	88 12       	call	r8		;
 8c8:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 8cc:	0c 4a       	mov	r10,	r12	;
 8ce:	0c 87       	sub	r7,	r12	;
 8d0:	b0 12 18 0c 	call	#3096		;#0x0c18
 8d4:	0e 4c       	mov	r12,	r14	;
 8d6:	7d 40 0b 00 	mov.b	#11,	r13	;#0x000b
 8da:	5c 43       	mov.b	#1,	r12	;r3 As==01
 8dc:	88 12       	call	r8		;
 8de:	3e 43       	mov	#-1,	r14	;r3 As==11
 8e0:	7d 40 0d 00 	mov.b	#13,	r13	;#0x000d
 8e4:	5c 43       	mov.b	#1,	r12	;r3 As==01
 8e6:	88 12       	call	r8		;
 8e8:	3e 43       	mov	#-1,	r14	;r3 As==11
 8ea:	7d 40 0e 00 	mov.b	#14,	r13	;#0x000e
 8ee:	5c 43       	mov.b	#1,	r12	;r3 As==01
 8f0:	88 12       	call	r8		;
 8f2:	09 93       	cmp	#0,	r9	;r3 As==00
 8f4:	06 20       	jnz	$+14     	;abs 0x902
 8f6:	3e 40 fe ff 	mov	#-2,	r14	;#0xfffe
 8fa:	7d 40 0c 00 	mov.b	#12,	r13	;#0x000c
 8fe:	30 40 8a 08 	br	#0x088a		;

00000902 <.L13>:
 902:	3e 43       	mov	#-1,	r14	;r3 As==11
 904:	7d 40 0c 00 	mov.b	#12,	r13	;#0x000c
 908:	30 40 9c 08 	br	#0x089c		;

0000090c <.L12>:
 90c:	3c 40 e7 03 	mov	#999,	r12	;#0x03e7
 910:	0c 9d       	cmp	r13,	r12	;
 912:	3a 28       	jnc	$+118    	;abs 0x988
 914:	38 40 20 0c 	mov	#3104,	r8	;#0x0c20
 918:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 91c:	0c 4a       	mov	r10,	r12	;
 91e:	88 12       	call	r8		;
 920:	05 4c       	mov	r12,	r5	;
 922:	0a 8c       	sub	r12,	r10	;
 924:	37 40 18 0c 	mov	#3096,	r7	;#0x0c18
 928:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 92c:	0c 4a       	mov	r10,	r12	;
 92e:	87 12       	call	r7		;
 930:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 934:	88 12       	call	r8		;
 936:	06 4c       	mov	r12,	r6	;
 938:	38 40 ba 07 	mov	#1978,	r8	;#0x07ba
 93c:	0e 45       	mov	r5,	r14	;
 93e:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 942:	5c 43       	mov.b	#1,	r12	;r3 As==01
 944:	88 12       	call	r8		;
 946:	0e 46       	mov	r6,	r14	;
 948:	7d 40 0b 00 	mov.b	#11,	r13	;#0x000b
 94c:	5c 43       	mov.b	#1,	r12	;r3 As==01
 94e:	88 12       	call	r8		;
 950:	7d 40 64 00 	mov.b	#100,	r13	;#0x0064
 954:	0c 4a       	mov	r10,	r12	;
 956:	0c 86       	sub	r6,	r12	;
 958:	87 12       	call	r7		;
 95a:	0e 4c       	mov	r12,	r14	;
 95c:	7d 40 0c 00 	mov.b	#12,	r13	;#0x000c
 960:	5c 43       	mov.b	#1,	r12	;r3 As==01
 962:	88 12       	call	r8		;
 964:	3e 43       	mov	#-1,	r14	;r3 As==11
 966:	7d 40 0e 00 	mov.b	#14,	r13	;#0x000e
 96a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 96c:	88 12       	call	r8		;
 96e:	09 93       	cmp	#0,	r9	;r3 As==00
 970:	06 20       	jnz	$+14     	;abs 0x97e
 972:	3e 40 fe ff 	mov	#-2,	r14	;#0xfffe
 976:	7d 40 0d 00 	mov.b	#13,	r13	;#0x000d
 97a:	30 40 8a 08 	br	#0x088a		;

0000097e <.L15>:
 97e:	3e 43       	mov	#-1,	r14	;r3 As==11
 980:	7d 40 0d 00 	mov.b	#13,	r13	;#0x000d
 984:	30 40 9c 08 	br	#0x089c		;

00000988 <.L14>:
 988:	3c 40 0f 27 	mov	#9999,	r12	;#0x270f
 98c:	0c 9d       	cmp	r13,	r12	;
 98e:	43 28       	jnc	$+136    	;abs 0xa16
 990:	38 40 20 0c 	mov	#3104,	r8	;#0x0c20
 994:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 998:	0c 4a       	mov	r10,	r12	;
 99a:	88 12       	call	r8		;
 99c:	04 4c       	mov	r12,	r4	;
 99e:	0a 8c       	sub	r12,	r10	;
 9a0:	37 40 18 0c 	mov	#3096,	r7	;#0x0c18
 9a4:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 9a8:	0c 4a       	mov	r10,	r12	;
 9aa:	87 12       	call	r7		;
 9ac:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 9b0:	88 12       	call	r8		;
 9b2:	05 4c       	mov	r12,	r5	;
 9b4:	0a 8c       	sub	r12,	r10	;
 9b6:	7d 40 64 00 	mov.b	#100,	r13	;#0x0064
 9ba:	0c 4a       	mov	r10,	r12	;
 9bc:	87 12       	call	r7		;
 9be:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 9c2:	88 12       	call	r8		;
 9c4:	06 4c       	mov	r12,	r6	;
 9c6:	38 40 ba 07 	mov	#1978,	r8	;#0x07ba
 9ca:	0e 44       	mov	r4,	r14	;
 9cc:	7d 40 0a 00 	mov.b	#10,	r13	;#0x000a
 9d0:	5c 43       	mov.b	#1,	r12	;r3 As==01
 9d2:	88 12       	call	r8		;
 9d4:	0e 45       	mov	r5,	r14	;
 9d6:	7d 40 0b 00 	mov.b	#11,	r13	;#0x000b
 9da:	5c 43       	mov.b	#1,	r12	;r3 As==01
 9dc:	88 12       	call	r8		;
 9de:	0e 46       	mov	r6,	r14	;
 9e0:	7d 40 0c 00 	mov.b	#12,	r13	;#0x000c
 9e4:	5c 43       	mov.b	#1,	r12	;r3 As==01
 9e6:	88 12       	call	r8		;
 9e8:	3d 40 e8 03 	mov	#1000,	r13	;#0x03e8
 9ec:	0c 4a       	mov	r10,	r12	;
 9ee:	0c 86       	sub	r6,	r12	;
 9f0:	87 12       	call	r7		;
 9f2:	0e 4c       	mov	r12,	r14	;
 9f4:	7d 40 0d 00 	mov.b	#13,	r13	;#0x000d
 9f8:	5c 43       	mov.b	#1,	r12	;r3 As==01
 9fa:	88 12       	call	r8		;
 9fc:	09 93       	cmp	#0,	r9	;r3 As==00
 9fe:	06 20       	jnz	$+14     	;abs 0xa0c
 a00:	3e 40 fe ff 	mov	#-2,	r14	;#0xfffe
 a04:	7d 40 0e 00 	mov.b	#14,	r13	;#0x000e
 a08:	30 40 8a 08 	br	#0x088a		;

00000a0c <.L17>:
 a0c:	3e 43       	mov	#-1,	r14	;r3 As==11
 a0e:	7d 40 0e 00 	mov.b	#14,	r13	;#0x000e
 a12:	30 40 9c 08 	br	#0x089c		;

00000a16 <.L16>:
 a16:	b1 40 ce 0d 	mov	#3534,	0(r1)	;#0x0dce
 a1a:	00 00 
 a1c:	b0 12 ae 07 	call	#1966		;#0x07ae
 a20:	59 43       	mov.b	#1,	r9	;r3 As==01
 a22:	30 40 8e 08 	br	#0x088e		;

00000a26 <neo430_cpu_delay_ms>:
 a26:	1e 42 fe ff 	mov	&0xfffe,r14	;0xfffe
 a2a:	0f 43       	clr	r15		;
 a2c:	0b 4e       	mov	r14,	r11	;
 a2e:	0b 5e       	add	r14,	r11	;
 a30:	0d 4f       	mov	r15,	r13	;
 a32:	0d 6f       	addc	r15,	r13	;
 a34:	0e 4c       	mov	r12,	r14	;
 a36:	0f 43       	clr	r15		;
 a38:	0c 4b       	mov	r11,	r12	;
 a3a:	b0 12 4e 0c 	call	#3150		;#0x0c4e

00000a3e <.L17>:
 a3e:	3c 53       	add	#-1,	r12	;r3 As==11
 a40:	3d 63       	addc	#-1,	r13	;r3 As==11
 a42:	3c 93       	cmp	#-1,	r12	;r3 As==11
 a44:	03 20       	jnz	$+8      	;abs 0xa4c
 a46:	3d 93       	cmp	#-1,	r13	;r3 As==11
 a48:	01 20       	jnz	$+4      	;abs 0xa4c
 a4a:	30 41       	ret			

00000a4c <.L18>:
 a4c:	03 43       	nop			
 a4e:	30 40 3e 0a 	br	#0x0a3e		;

00000a52 <neo430_gpio_pin_set>:
 a52:	0a 12       	push	r10		;
 a54:	09 12       	push	r9		;
 a56:	4d 4c       	mov.b	r12,	r13	;
 a58:	3a 40 ac ff 	mov	#-84,	r10	;#0xffac
 a5c:	29 4a       	mov	@r10,	r9	;
 a5e:	5c 43       	mov.b	#1,	r12	;r3 As==01
 a60:	b0 12 3c 0c 	call	#3132		;#0x0c3c
 a64:	0c d9       	bis	r9,	r12	;
 a66:	8a 4c 00 00 	mov	r12,	0(r10)	;
 a6a:	30 40 32 0c 	br	#0x0c32		;

00000a6e <neo430_gpio_pin_clr>:
 a6e:	0a 12       	push	r10		;
 a70:	09 12       	push	r9		;
 a72:	4d 4c       	mov.b	r12,	r13	;
 a74:	3a 40 ac ff 	mov	#-84,	r10	;#0xffac
 a78:	29 4a       	mov	@r10,	r9	;
 a7a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 a7c:	b0 12 3c 0c 	call	#3132		;#0x0c3c
 a80:	09 cc       	bic	r12,	r9	;
 a82:	8a 49 00 00 	mov	r9,	0(r10)	;
 a86:	30 40 32 0c 	br	#0x0c32		;

00000a8a <neo430_gpio_port_set>:
 a8a:	82 4c ac ff 	mov	r12,	&0xffac	;
 a8e:	30 41       	ret			

00000a90 <neo430_gpio_pin_get>:
 a90:	0a 12       	push	r10		;
 a92:	4d 4c       	mov.b	r12,	r13	;
 a94:	1a 42 aa ff 	mov	&0xffaa,r10	;0xffaa
 a98:	5c 43       	mov.b	#1,	r12	;r3 As==01
 a9a:	b0 12 3c 0c 	call	#3132		;#0x0c3c
 a9e:	0c fa       	and	r10,	r12	;
 aa0:	0d 43       	clr	r13		;
 aa2:	0d 8c       	sub	r12,	r13	;
 aa4:	0c dd       	bis	r13,	r12	;
 aa6:	7d 40 0f 00 	mov.b	#15,	r13	;#0x000f
 aaa:	b0 12 48 0c 	call	#3144		;#0x0c48
 aae:	3a 41       	pop	r10		;
 ab0:	30 41       	ret			

00000ab2 <neo430_spi_enable>:
 ab2:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 ab6:	3d 40 a4 ff 	mov	#-92,	r13	;#0xffa4
 aba:	8d 43 00 00 	mov	#0,	0(r13)	;r3 As==00
 abe:	0c 5c       	rla	r12		;
 ac0:	0c 5c       	rla	r12		;
 ac2:	0c 5c       	rla	r12		;
 ac4:	0c 5c       	rla	r12		;
 ac6:	0c 5c       	rla	r12		;
 ac8:	0c 5c       	rla	r12		;
 aca:	0c 5c       	rla	r12		;
 acc:	0c 5c       	rla	r12		;
 ace:	0c 5c       	rla	r12		;
 ad0:	3c d0 40 20 	bis	#8256,	r12	;#0x2040
 ad4:	8d 4c 00 00 	mov	r12,	0(r13)	;
 ad8:	30 41       	ret			

00000ada <neo430_spi_cs_en>:
 ada:	0a 12       	push	r10		;
 adc:	09 12       	push	r9		;
 ade:	4d 4c       	mov.b	r12,	r13	;
 ae0:	3a 40 a4 ff 	mov	#-92,	r10	;#0xffa4
 ae4:	29 4a       	mov	@r10,	r9	;
 ae6:	5c 43       	mov.b	#1,	r12	;r3 As==01
 ae8:	b0 12 3c 0c 	call	#3132		;#0x0c3c
 aec:	0c d9       	bis	r9,	r12	;
 aee:	8a 4c 00 00 	mov	r12,	0(r10)	;
 af2:	30 40 32 0c 	br	#0x0c32		;

00000af6 <neo430_spi_cs_dis>:
 af6:	b2 f0 c0 ff 	and	#-64,	&0xffa4	;#0xffc0
 afa:	a4 ff 
 afc:	30 41       	ret			

00000afe <neo430_spi_trans>:
 afe:	3d 40 a6 ff 	mov	#-90,	r13	;#0xffa6
 b02:	8d 4c 00 00 	mov	r12,	0(r13)	;
 b06:	3e 40 a4 ff 	mov	#-92,	r14	;#0xffa4

00000b0a <.L6>:
 b0a:	2c 4e       	mov	@r14,	r12	;
 b0c:	0c 93       	cmp	#0,	r12	;r3 As==00
 b0e:	fd 3b       	jl	$-4      	;abs 0xb0a
 b10:	2c 4d       	mov	@r13,	r12	;
 b12:	30 41       	ret			

00000b14 <neo430_uart_setup>:
 b14:	0a 12       	push	r10		;
 b16:	09 12       	push	r9		;
 b18:	1a 42 fc ff 	mov	&0xfffc,r10	;0xfffc
 b1c:	1b 42 fe ff 	mov	&0xfffe,r11	;0xfffe
 b20:	0e 4c       	mov	r12,	r14	;
 b22:	0e 5c       	add	r12,	r14	;
 b24:	0f 4d       	mov	r13,	r15	;
 b26:	0f 6d       	addc	r13,	r15	;
 b28:	4c 43       	clr.b	r12		;
 b2a:	09 4f       	mov	r15,	r9	;

00000b2c <.L2>:
 b2c:	0b 9f       	cmp	r15,	r11	;
 b2e:	04 28       	jnc	$+10     	;abs 0xb38
 b30:	09 9b       	cmp	r11,	r9	;
 b32:	1b 20       	jnz	$+56     	;abs 0xb6a
 b34:	0a 9e       	cmp	r14,	r10	;
 b36:	19 2c       	jc	$+52     	;abs 0xb6a

00000b38 <.L10>:
 b38:	4a 43       	clr.b	r10		;
 b3a:	79 40 03 00 	mov.b	#3,	r9	;

00000b3e <.L5>:
 b3e:	7d 40 ff 00 	mov.b	#255,	r13	;#0x00ff
 b42:	0d 9c       	cmp	r12,	r13	;
 b44:	17 28       	jnc	$+48     	;abs 0xb74
 b46:	82 43 a0 ff 	mov	#0,	&0xffa0	;r3 As==00
 b4a:	0d 4a       	mov	r10,	r13	;
 b4c:	0d 5a       	add	r10,	r13	;
 b4e:	0d 5d       	rla	r13		;
 b50:	0d 5d       	rla	r13		;
 b52:	0d 5d       	rla	r13		;
 b54:	0d 5d       	rla	r13		;
 b56:	0d 5d       	rla	r13		;
 b58:	0d 5d       	rla	r13		;
 b5a:	0d 5d       	rla	r13		;
 b5c:	0d dc       	bis	r12,	r13	;
 b5e:	3d d0 00 10 	bis	#4096,	r13	;#0x1000
 b62:	82 4d a0 ff 	mov	r13,	&0xffa0	;
 b66:	30 40 32 0c 	br	#0x0c32		;

00000b6a <.L3>:
 b6a:	0a 8e       	sub	r14,	r10	;
 b6c:	0b 7f       	subc	r15,	r11	;
 b6e:	1c 53       	inc	r12		;
 b70:	30 40 2c 0b 	br	#0x0b2c		;

00000b74 <.L9>:
 b74:	6a 93       	cmp.b	#2,	r10	;r3 As==10
 b76:	02 24       	jz	$+6      	;abs 0xb7c
 b78:	6a 92       	cmp.b	#4,	r10	;r2 As==10
 b7a:	08 20       	jnz	$+18     	;abs 0xb8c

00000b7c <.L6>:
 b7c:	0d 49       	mov	r9,	r13	;
 b7e:	b0 12 48 0c 	call	#3144		;#0x0c48

00000b82 <.L8>:
 b82:	5a 53       	inc.b	r10		;
 b84:	3a f0 ff 00 	and	#255,	r10	;#0x00ff
 b88:	30 40 3e 0b 	br	#0x0b3e		;

00000b8c <.L7>:
 b8c:	12 c3       	clrc			
 b8e:	0c 10       	rrc	r12		;
 b90:	30 40 82 0b 	br	#0x0b82		;

00000b94 <neo430_uart_putc>:
 b94:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 b98:	3e 40 a0 ff 	mov	#-96,	r14	;#0xffa0

00000b9c <.L17>:
 b9c:	2d 4e       	mov	@r14,	r13	;
 b9e:	0d 93       	cmp	#0,	r13	;r3 As==00
 ba0:	fd 3b       	jl	$-4      	;abs 0xb9c
 ba2:	82 4c a2 ff 	mov	r12,	&0xffa2	;
 ba6:	30 41       	ret			

00000ba8 <neo430_uart_br_print>:
 ba8:	0a 12       	push	r10		;
 baa:	09 12       	push	r9		;
 bac:	08 12       	push	r8		;
 bae:	07 12       	push	r7		;
 bb0:	09 4c       	mov	r12,	r9	;
 bb2:	38 40 94 0b 	mov	#2964,	r8	;#0x0b94
 bb6:	77 40 0d 00 	mov.b	#13,	r7	;#0x000d

00000bba <.L28>:
 bba:	6a 49       	mov.b	@r9,	r10	;
 bbc:	0a 93       	cmp	#0,	r10	;r3 As==00
 bbe:	02 20       	jnz	$+6      	;abs 0xbc4
 bc0:	30 40 2e 0c 	br	#0x0c2e		;

00000bc4 <.L30>:
 bc4:	3a 90 0a 00 	cmp	#10,	r10	;#0x000a
 bc8:	02 20       	jnz	$+6      	;abs 0xbce
 bca:	4c 47       	mov.b	r7,	r12	;
 bcc:	88 12       	call	r8		;

00000bce <.L29>:
 bce:	4c 4a       	mov.b	r10,	r12	;
 bd0:	88 12       	call	r8		;
 bd2:	19 53       	inc	r9		;
 bd4:	30 40 ba 0b 	br	#0x0bba		;

00000bd8 <udivmodhi4>:
 bd8:	7f 40 11 00 	mov.b	#17,	r15	;#0x0011

00000bdc <.Loc.35.1>:
 bdc:	5b 43       	mov.b	#1,	r11	;r3 As==01

00000bde <.L2>:
 bde:	0d 9c       	cmp	r12,	r13	;
 be0:	05 2c       	jc	$+12     	;abs 0xbec
 be2:	3f 53       	add	#-1,	r15	;r3 As==11

00000be4 <.Loc.38.1>:
 be4:	0f 93       	cmp	#0,	r15	;r3 As==00
 be6:	05 24       	jz	$+12     	;abs 0xbf2

00000be8 <.Loc.38.1>:
 be8:	0d 93       	cmp	#0,	r13	;r3 As==00
 bea:	08 34       	jge	$+18     	;abs 0xbfc

00000bec <.L10>:
 bec:	4f 43       	clr.b	r15		;

00000bee <.L6>:
 bee:	0b 93       	cmp	#0,	r11	;r3 As==00
 bf0:	09 20       	jnz	$+20     	;abs 0xc04

00000bf2 <.L4>:
 bf2:	0e 93       	cmp	#0,	r14	;r3 As==00
 bf4:	01 24       	jz	$+4      	;abs 0xbf8
 bf6:	0f 4c       	mov	r12,	r15	;

00000bf8 <.L1>:
 bf8:	0c 4f       	mov	r15,	r12	;
 bfa:	30 41       	ret			

00000bfc <.L5>:
 bfc:	0d 5d       	rla	r13		;

00000bfe <.Loc.41.1>:
 bfe:	0b 5b       	rla	r11		;
 c00:	30 40 de 0b 	br	#0x0bde		;

00000c04 <.L8>:
 c04:	0c 9d       	cmp	r13,	r12	;
 c06:	02 28       	jnc	$+6      	;abs 0xc0c

00000c08 <.Loc.47.1>:
 c08:	0c 8d       	sub	r13,	r12	;

00000c0a <.Loc.48.1>:
 c0a:	0f db       	bis	r11,	r15	;

00000c0c <.L7>:
 c0c:	12 c3       	clrc			
 c0e:	0b 10       	rrc	r11		;

00000c10 <.Loc.51.1>:
 c10:	12 c3       	clrc			
 c12:	0d 10       	rrc	r13		;
 c14:	30 40 ee 0b 	br	#0x0bee		;

00000c18 <__mspabi_divu>:
 c18:	4e 43       	clr.b	r14		;
 c1a:	b0 12 d8 0b 	call	#3032		;#0x0bd8

00000c1e <.LVL33>:
 c1e:	30 41       	ret			

00000c20 <__mspabi_remu>:
 c20:	5e 43       	mov.b	#1,	r14	;r3 As==01
 c22:	b0 12 d8 0b 	call	#3032		;#0x0bd8

00000c26 <.LVL35>:
 c26:	30 41       	ret			

00000c28 <__mspabi_func_epilog_7>:
 c28:	34 41       	pop	r4		;

00000c2a <__mspabi_func_epilog_6>:
 c2a:	35 41       	pop	r5		;

00000c2c <__mspabi_func_epilog_5>:
 c2c:	36 41       	pop	r6		;

00000c2e <__mspabi_func_epilog_4>:
 c2e:	37 41       	pop	r7		;

00000c30 <__mspabi_func_epilog_3>:
 c30:	38 41       	pop	r8		;

00000c32 <__mspabi_func_epilog_2>:
 c32:	39 41       	pop	r9		;

00000c34 <__mspabi_func_epilog_1>:
 c34:	3a 41       	pop	r10		;
 c36:	30 41       	ret			

00000c38 <.L11>:
 c38:	3d 53       	add	#-1,	r13	;r3 As==11
 c3a:	0c 5c       	rla	r12		;

00000c3c <__mspabi_slli>:
 c3c:	0d 93       	cmp	#0,	r13	;r3 As==00
 c3e:	fc 23       	jnz	$-6      	;abs 0xc38
 c40:	30 41       	ret			

00000c42 <.L11>:
 c42:	3d 53       	add	#-1,	r13	;r3 As==11
 c44:	12 c3       	clrc			
 c46:	0c 10       	rrc	r12		;

00000c48 <__mspabi_srli>:
 c48:	0d 93       	cmp	#0,	r13	;r3 As==00
 c4a:	fb 23       	jnz	$-8      	;abs 0xc42
 c4c:	30 41       	ret			

00000c4e <__mspabi_mpyl>:
 c4e:	0a 12       	push	r10		;

00000c50 <.LCFI0>:
 c50:	09 12       	push	r9		;

00000c52 <.LCFI1>:
 c52:	08 12       	push	r8		;

00000c54 <.LCFI2>:
 c54:	07 12       	push	r7		;

00000c56 <.LCFI3>:
 c56:	06 12       	push	r6		;

00000c58 <.LCFI4>:
 c58:	0a 4c       	mov	r12,	r10	;
 c5a:	0b 4d       	mov	r13,	r11	;

00000c5c <.LVL1>:
 c5c:	7d 40 21 00 	mov.b	#33,	r13	;#0x0021

00000c60 <.Loc.30.1>:
 c60:	48 43       	clr.b	r8		;
 c62:	49 43       	clr.b	r9		;

00000c64 <.L2>:
 c64:	0c 4e       	mov	r14,	r12	;
 c66:	0c df       	bis	r15,	r12	;
 c68:	0c 93       	cmp	#0,	r12	;r3 As==00
 c6a:	05 24       	jz	$+12     	;abs 0xc76
 c6c:	7d 53       	add.b	#-1,	r13	;r3 As==11

00000c6e <.LVL3>:
 c6e:	3d f0 ff 00 	and	#255,	r13	;#0x00ff

00000c72 <.Loc.34.1>:
 c72:	0d 93       	cmp	#0,	r13	;r3 As==00
 c74:	04 20       	jnz	$+10     	;abs 0xc7e

00000c76 <.L1>:
 c76:	0c 48       	mov	r8,	r12	;
 c78:	0d 49       	mov	r9,	r13	;
 c7a:	30 40 2c 0c 	br	#0x0c2c		;

00000c7e <.L6>:
 c7e:	0c 4e       	mov	r14,	r12	;
 c80:	5c f3       	and.b	#1,	r12	;r3 As==01

00000c82 <.Loc.36.1>:
 c82:	0c 93       	cmp	#0,	r12	;r3 As==00
 c84:	02 24       	jz	$+6      	;abs 0xc8a

00000c86 <.Loc.37.1>:
 c86:	08 5a       	add	r10,	r8	;

00000c88 <.LVL4>:
 c88:	09 6b       	addc	r11,	r9	;

00000c8a <.L3>:
 c8a:	06 4a       	mov	r10,	r6	;
 c8c:	07 4b       	mov	r11,	r7	;
 c8e:	06 5a       	add	r10,	r6	;
 c90:	07 6b       	addc	r11,	r7	;
 c92:	0a 46       	mov	r6,	r10	;

00000c94 <.LVL6>:
 c94:	0b 47       	mov	r7,	r11	;

00000c96 <.LVL7>:
 c96:	12 c3       	clrc			
 c98:	0f 10       	rrc	r15		;
 c9a:	0e 10       	rrc	r14		;

00000c9c <.LVL8>:
 c9c:	30 40 64 0c 	br	#0x0c64		;

Disassembly of section .rodata:

00000ca0 <_etext-0x178>:
 ca0:	77 72       	subc.b	#8,	r7	;r2 As==11
 ca2:	69 74       	subc.b	@r4,	r9	;
 ca4:	65 20       	jnz	$+204    	;abs 0xd70
 ca6:	61 64       	addc.b	@r4,	r1	;
 ca8:	64 72       	subc.b	#4,	r4	;r2 As==10
 caa:	3a 20       	jnz	$+118    	;abs 0xd20
 cac:	25 58       	add	@r8,	r5	;
 cae:	0d 0a       	mova	@r10,	r13	;
 cb0:	00 72       	subc	r2,	r0	;
 cb2:	65 61       	addc.b	@r1,	r5	;
 cb4:	64 20       	jnz	$+202    	;abs 0xd7e
 cb6:	61 64       	addc.b	@r4,	r1	;
 cb8:	64 72       	subc.b	#4,	r4	;r2 As==10
 cba:	3a 20       	jnz	$+118    	;abs 0xd30
 cbc:	25 58       	add	@r8,	r5	;
 cbe:	0d 0a       	mova	@r10,	r13	;
 cc0:	00 72       	subc	r2,	r0	;
 cc2:	6f 77       	subc.b	@r7,	r15	;
 cc4:	5f 61 64 64 	addc.b	25700(r1),r15	;0x06464
 cc8:	72 20       	jnz	$+230    	;abs 0xdae
 cca:	6d 75       	subc.b	@r5,	r13	;
 ccc:	
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