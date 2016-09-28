	DEVICE	ZXSPECTRUM128

NOBYTE	EQU 	23726
HGT		EQU 	38
SECBUF	EQU	#7000
BUF		EQU	#7700
BIGBUF	EQU	#8000
FONTS		EQU 	#7800

		ORG	#7000


main
	CALL	TERMINAL_INIT
	call	UART_INIT
NEXT
	CALL	TERMINAL_INPUT
	OR	A
	JR	Z,BREAK
	ld	hl,BUF
	push	hl
.lp1	ld	a,(hl)
	inc	hl
	or	a
	jr	nz,.lp1
	dec	hl
	ld	(hl),13
	inc	hl
	ld	(hl),10
	inc	hl
	ld	(hl),0
	pop	hl
	call	UART_WRITE
	; HL - TEXT
	ld	hl,BIGBUF
	push	hl
	call	UART_READ
	CALL	UART_READ
	CALL	UART_READ
	pop	hl
	ld	a,(hl)
	inc	a
	jr	nz,.lp2
	ld	hl,err_esp	
.lp2	CALL	TERMINAL_PRINT

	JR	NEXT

BREAK
	RET 


TERMINAL_INIT

		CALL	DEPKFNT
		CALL	CLRSCR

		LD	HL,#0000
		LD	(COORD),  HL

		RET 

TERMINAL_PRINT
		LD	BC,(COORD)
		CALL	CALC_ADDR
		CALL	PRLINE
		LD	BC,(COORD)
NEXTLINE
	;	INC	C
NEXTCHAR
		LD	A,(hl)
		OR	A
		JR	Z,FINCHAR
		INC	HL
		INC	B
		LD	A,41
		CP	B
		JR	NC,NEXTCHAR
		LD	B,0
		CALL	SCROLLDOWN
		JR	NEXTLINE
FINCHAR
		LD	B,0
		CALL	SCROLLDOWN
		RET 


TERMINAL_INPUT
		XOR	A
		LD	(PRINT_CURSOR+1),A
		LD	BC,BUF
CLRBUF
		LD	(BC),A
		INC	C
		JR	NZ,CLRBUF
		LD	BC,(COORD)
		CALL	CALC_ADDR
NOQ
		LD	HL,BUF
		PUSH	DE
		CALL	PRLINE
		POP	DE
		LD	HL,23611
		RES	5,(hl)
WAIT
		EI 
		HALT 
		CALL	PRINT_CURSOR

		BIT	5,(hl)
		JR	Z,WAIT

		CALL	#1F54
		JR	NC,QQQ

		LD	A,(23560)
		CP	32
		JR	NC,NEWSYM
		CP	13
		JR	Z,OK
		CP	12
		JR	NZ,NOBACK
		LD	A,B
		OR	A
		JR	NZ,BACK
		LD	A,(COORD)
		CP	C
		JR	Z,NOBACK
		DEC	C
		LD	B,42
BACK
		CALL	CALCBUF
		LD	(hl),0
		DEC	B
NOBACK

OK
		CALL	DEL_CURSOR
		LD	B,0
		CALL	SCROLLDOWN
		LD	HL,BUF
		LD	A,1
		RET 

QQQ
		XOR	A	; exit
		RET 

SCROLLDOWN
		LD	A,C
		CP	23
		JR	C,SCROLLNORM
		CALL	SCROLL
		DEC	C
SCROLLNORM
		INC	C
		LD	(COORD),BC
		RET 

NEWSYM
		ex	af,af'
		CALL	CALCBUF
		ex	af,af'
		LD	(hl),A
		CALL	DEL_CURSOR
		INC	B
		LD	A,41
		CP	B
		JR	NC,NOQ
		LD	B,0
		INC	C
		JR	NOQ

CALCBUF
		LD	A,(COORD)
		SUB	C
		LD	L,A
		LD	A,B
		JR	Z,FIRST
NEXTLIN
		ADD	A,42
		INC	L
		JR	NZ,NEXTLIN
FIRST
		LD	HL,BUF
		LD	L,A
		RET 

SCROLL	PUSH	BC
		LD	B,23
		LD HL,#4000
SCROL0	PUSH BC
		LD D,H
		LD E,L
		CALL NXTLINE
		EX DE,HL
		PUSH HL
		LD BC,#7FF
SCROL1	INC H
		INC D
		PUSH DE
		PUSH HL
		DUP 32
		LDI 
		EDUP 
		POP HL
		POP DE
		DJNZ SCROL1
		POP HL
		POP BC
		DJNZ SCROL0
		LD	BC,#800
SCROLB
		PUSH	HL
SCROLC
		LD	(hl),C
		INC	L
		JR	NZ,SCROLC
		POP	HL
		INC	H
		DJNZ	SCROLB
		POP	BC
		RET 

DEL_CURSOR
		LD	A,(PRINT_CURSOR+1)
		AND	#10
		JR	Z,NOCUR
		XOR	A
		CALL	CLR_CURSOR
NOCUR
		RET 

PRINT_CURSOR
		LD	A,0
		INC	A
CLR_CURSOR
		LD	(PRINT_CURSOR+1),A
		AND	#0F
		RET	NZ
		PUSH	HL
		PUSH	DE
		LD	A,C
		AND	#18
		ADD	A,#46
		LD	H,A
		LD	A,C
		AND	#7
		RRCA 
		RRCA 
		RRCA 
		LD	L,A
		LD	A,B
		AND	#3C
		LD	E,A
		ADD	A,L
		RRC	E
		RRC	E
		SUB	E
		LD	L,A
		LD	A,B
		AND	3
		LD	E,#7C
		JR	Z,NOROT
		LD	DE,#1F0
		DEC	A
		JR	Z,TWO
		LD	DE,#7C0
		INC	L
		DEC	A
		JR	Z,TWO
		LD	E,#1F
		INC	L
NOROT
		LD	A,(hl)
		XOR	E
		LD	(hl),A
		INC	H
		LD	A,(hl)
		XOR	E
		LD	(hl),A
		POP	DE
		POP	HL
		RET 
TWO
		LD	A,(hl)
		XOR	D
		LD	(hl),A
		INC	L
		LD	A,(hl)
		XOR	E
		LD	(hl),A
		INC	H
		LD	A,(hl)
		XOR	E
		LD	(hl),A
		DEC	L
		LD	A,(hl)
		XOR	D
		LD	(hl),A
		POP	DE
		POP	HL
		RET 

CALC_ADDR
		PUSH	BC
		LD	A,C
		AND	#18
		ADD	A,#40
		LD	D,A
		LD	A,C
		AND	#7
		RRCA 
		RRCA 
		RRCA 
		LD	E,A
		LD	A,B
		AND	#3C
		LD	C,A
		ADD	A,E
		RRC	C
		RRC	C
		SUB	C
		LD	E,A
		LD	A,B
		AND	3
		JR	Z,FINIS
		DEC	A
		JR	Z,FINIS
		INC	E
		JR	Z,FINIS
		INC	E
FINIS
		POP	BC
		RET 

COORD		DEFB	0,0


CLRSCR
		LD HL,#4000
		LD DE,#4001
		LD BC,#1800
		LD (hl),L
		LDIR 
		LD BC,#2FF
		LD (hl),7
		LDIR 
		RET 

CTRLS		DEFW PGUP,PGDN,DOWN,UP

SETIM		DI 
		LD A,#77
		LD H,A
		LD L,255
		LD DE,IMER
		LD (hl),E
		INC HL
		LD (hl),D
		LD I,A
		EI 
		RET 

IMER		PUSH AF
		PUSH BC
		PUSH DE
		PUSH HL
		LD A,31
		LD BC,32765
		OUT (C),A
		PUSH BC
		LD HL,#D800
		LD DE,#D801
		LD BC,255
		LD (hl),7
		LDIR 
		LD HL,486;348
IMER0		DEC HL
		LD A,H
		OR L
		JR NZ,IMER0
		POP BC
		LD A,23
		OUT (C),A
		PUSH BC
		LD HL,#D800
		LD DE,#D801
		LD BC,255
		LD (hl),L
		LDIR 
		LD HL,1435
IMER1		DEC HL
		LD A,H
		OR L
		JR NZ,IMER1
		POP BC
		LD A,31
		OUT (C),A
		POP HL
		POP DE
		POP BC
		POP AF
		RST 56
		RET 

PRCATDO	POP AF

PRCAT		CALL CLS
		LD DE,0
		LD HL,#4000
		LD BC,SECBUF
		PUSH BC
PRCAT0	PUSH DE
		PUSH BC
		PUSH HL
		LD H,B
		LD L,0
		LD BC,#105
		PUSH HL
		CALL #3D13
		POP HL
		POP DE
		POP BC
PRCAT1	LD A,(hl)
		OR A
		JR Z,PRCATQ
		SET 3,L
		LD A,(hl)
		RES 3,L
		CP "B"
		JR Z,PRCATNO
		CP "H"
		JR Z,PRCATNO
		PUSH BC
		LD BC,#808
PRCAT2	LD A,(hl)
		INC HL
		CALL PRSYM
		DJNZ PRCAT2
		LD A,"."
		CALL PRSYM
		LD A,(hl)
		CALL PRSYM
		INC E
		JR NZ,$+6
		LD A,D
		ADD A,8
		LD D,A
		POP BC
		INC C
		LD A,C
		CP 96
		JR Z,PRCATQ
		LD A,8
		JR $+6
PRCATNO	LD (hl),0
		LD A,16
		ADD A,L
		LD L,A
		JR NZ,PRCAT1
		EX DE,HL
		POP DE
		INC B
		INC E
		BIT 3,E
		JR Z,PRCAT0
		JR $+3
PRCATQ	POP DE
		LD (23728),BC
		LD A,23
		CALL SETSCRN+2
		LD B,0
		LD HL,#5800

PRCATST	CALL CURSOR
		RES 5,(IY+1)
PRCATKY	BIT 5,(IY+1)
		JR Z,PRCATKY
		CALL CURRES
		LD DE,0
		LD A,(23560)
		CP " "
		JP Z,PRCATDO
		SUB 8
		JR NZ,PRCATNL
		DEC B
		INC B
		JR Z,PRCATST
		DEC B
		LD DE,-8
PRCATNL	DEC A
		JR NZ,PRCATNR
		LD A,B
		INC A
		SUB C
		JR NC,PRCATST
		INC B
		LD E,8
PRCATNR	DEC A
		JR NZ,PRCATND
		LD A,B
		ADD A,4
		CP C
		JR NC,PRCATST
		LD B,A
		LD A,H
		LD E,32
PRCATND	DEC A
		JR NZ,PRCATNU
		LD A,B
		SUB 4
		JR C,PRCATST
		LD B,A
		LD DE,-32
PRCATNU	ADD HL,DE
		CALL 8020
		JR NC,GOOUT
		LD A,(23560)
		CP 13
		JR NZ,PRCATST
		POP HL
		LD A,B
		LD BC,16
PRCATF	DEC (hl)
		INC (hl)
		ADD HL,BC
		JR Z,PRCATF
		SUB 1
		JR NC,PRCATF

		LD BC,#7FFD
		LD A,#10
		OUT (C),A

		EX AF,AF'
		DEC HL
		LD D,(hl)
		DEC HL
		LD E,(hl)
		DEC HL
		LD B,(hl)
		DEC HL
		LD C,5
		LD A,(hl)
		DEC HL
		LD L,(hl)
		LD H,A
		LD (NOBYTE),HL

LDNXPAG	PUSH BC
		EX AF,AF'
		PUSH AF
		LD A,64
		CP B
		JR NC,$+3
		LD B,A
		LD HL,#C000
		CALL 15635
		POP AF
		LD BC,32765
		INC A
		OUT (C),A

		POP BC
		LD DE,(23796)
		EX AF,AF'
		LD A,B
		SUB 65
		RET C
		INC A
		LD B,A
		JR LDNXPAG

CURRES	PUSH BC
		LD C,7
		JR $+5

CURSOR	PUSH BC
	LD C,#38

	PUSH HL
	LD B,8
CURSOR0	LD (hl),C
	INC L
	DJNZ CURSOR0
GOOUT	POP HL

	POP BC
	RET 

CLS	CALL SETSCRN
	LD HL,#4000
	LD DE,#4001
	LD BC,#1800
	LD (hl),L
	LDIR 
	LD BC,#2FF
	LD (hl),7
	LDIR 
	LD HL,#C000
	LD DE,#C001
	LD BC,#1FFF
	LD (hl),L
	LDIR 
	LD HL,#D800
	LD DE,#D801
	DEC C
	LD (hl),7
	LDIR 
	LD HL,#DB00
	LD DE,#DB01
	DEC C
	LD (hl),7
	LDIR 
	RET 

PREPAGE	DI 
	CALL CLS
	LD HL,0
	LD (TOP),HL
	LD DE,#C000
	LD B,HGT

PREPAG0	DEC HL
	CALL ISITEND
	JR Z,PREPAGQ

	INC HL
	CALL PRLINE
	CALL NXTLINE
	DJNZ PREPAG0

PREPAGQ	LD (BOTTOM),HL
	EI 
	RET 

DOWN	LD HL,(BOTTOM)
	DEC HL
	CALL ISITEND
	INC HL
	RET Z
	CALL LINEDN
	LD (BOTTOM),HL
	PUSH HL
	LD HL,(TOP)
	CALL LINEDN
	LD (TOP),HL
	CALL SCRUP
	POP HL
	LD DE,#D8A0
	JR PRLINE

PGUP
TOP	EQU $+1
	LD HL,0
	CALL ISITST
	RET Z
PGUP2	LD B,HGT
	DI 
	LD A,16
	LD (GETBYTA+1),A
	LD A,23
	CALL SETSCRN+2
PGUP0	CALL LINEUP
	DJNZ PGUP0
	JR PRPAGE

PGDN	LD HL,(BOTTOM)
	CALL ISITEND
	RET Z

PRPAGE	LD (TOP),HL
	DI 
	LD A,16
	LD (GETBYTA+1),A
	LD A,23
	LD (SETSCRN+1),A
	CALL SETSCRN
PRPAGER	LD DE,#C000
	LD B,HGT
PRPAGE0	DEC HL
	CALL ISITEND
	JR Z,PGUP2
	INC HL
	CALL PRLINE
	CALL NXTLINE
	DJNZ PRPAGE0
	LD (BOTTOM),HL
	LD A,24
	LD (GETBYTA+1),A
	LD A,31
	LD (SETSCRN+1),A
	EI 
	RET 

UP	LD HL,(TOP)
	CALL ISITST
	RET Z
	CALL LINEUP
	LD (TOP),HL
	PUSH HL
BOTTOM	EQU $+1
	LD HL,0
	CALL LINEUP
	LD (BOTTOM),HL
	CALL SCRDN
	POP HL

PRINT_PAGE
	LD DE,#4000

PRLINE	PUSH BC

	PUSH DE
	DEC E
	PUSH HL
MORE
	LD BC,#2A02
PRLINE0
;	CALL ISITEND
;	JR Z,PRLINEQ
;	CALL GETBYTE

	LD	A,(hl)
	OR	A
	JR	Z,EOT
	INC	HL
	CP	13
	JR	Z,PRLINEQ
	CALL	PRSYM
	DJNZ	PRLINE0
	POP	DE
	POP	DE
	CALL	NXTLINE
	PUSH	DE
	DEC	E
	PUSH	HL
	JR	MORE


PRLINEQ	LD A,B
	OR A
	JR NZ,PRLINEC

	POP HL
	CALL LINEDN
	POP DE
	POP BC
	JP LF
EOT
	POP	HL
	POP	DE
	POP	BC
	RET 

PRLINEC	LD A,32
	CALL PRSYM
	DEC B
	JR PRLINEQ

LINEUP	CALL ISITST
	RET Z
	DEC HL
	CALL GETBYTE
	CP 10
	JR NZ,$+3
	DEC HL
LINEUP0	DEC HL
	CALL ISITST
	RET Z
	CALL GETBYTE
	CP 13
	JR NZ,LINEUP0
LINEUPQ	INC HL


LF   ;	CALL ISITEND
     ;	RET Z
     ;	CALL GETBYTE
	LD	A,(hl)
	CP 10
	RET NZ
	INC HL
	RET 

LINEDN ;CALL GETBYTE
       ;CALL ISITEND

	LD	A,(hl)
	INC HL
	RET Z
	CP 13
	JR NZ,LINEDN
	JR LF

NXTLINE	LD A,E
	ADD A,32
	LD E,A
	RET NC
	LD A,D
	ADD A,8
	LD D,A
	CP #58
	JR NZ,$+4
	LD D,#40
	RET 

SCRDN	LD B,HGT-1
	CALL SETSCRN
	LD HL,#D8A0
SCRDN0	PUSH BC
	LD D,H
	LD E,L
	LD A,L
	SUB 32
	LD L,A
	JR NC,SCRDNN
	LD A,H
	SUB 8
	LD H,A
	CP #D0
	JR NZ,$+4
	LD H,#50
	CP #38
	JR NZ,$+4
	LD H,#C0
SCRDNN	PUSH HL
	LD BC,#7FF
SCRDN1	INC H
	INC D
	LD A,D
	CP #DB
	JR NZ,$+4
	LD D,#C8
	CP #C9
	JR NZ,$+4
	LD D,#DC
	LD A,H
	CP #DB
	JR NZ,$+4
	LD H,#C8
	CP #C9
	JR NZ,$+4
	LD H,#DC
	PUSH DE
	PUSH HL
	DUP 32
	LDI 
	EDUP 
	POP HL
	POP DE
	DJNZ SCRDN1
	POP HL
	POP BC
	DEC B
	JP NZ,SCRDN0
		RET 

SCRUP		LD B,HGT-1
		CALL SETSCRN
		LD HL,#C000
SCRUP0	PUSH BC
		LD D,H
		LD E,L
		CALL NXTLINE
		EX DE,HL
		PUSH HL
		LD BC,#7FF
SCRUP1	INC H
		INC D
		LD A,D
		CP #DB
		JR NZ,$+4
		LD D,#C8
		CP #C9
		JR NZ,$+4
		LD D,#DC
		LD A,H
		CP #DB
		JR NZ,$+4
		LD H,#C8
		CP #C9
		JR NZ,$+4
		LD H,#DC
		PUSH DE
		PUSH HL
		DUP 32
		LDI 
		EDUP 
		POP HL
		POP DE
		DJNZ SCRUP1
		POP HL
		POP BC
		DJNZ SCRUP0
		RET 

SETSCRN	LD A,31
		PUSH BC
		OUT (C),A
		POP BC
		RET 

PRSYM	PUSH BC
	PUSH DE
	PUSH HL
	LD L,A
	LD H,#0f
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD B,C
	LD A,1
	RRCA 
	DJNZ $-1
	LD (PRN+1),A
;	CALL SETSCRN

	LD B,7
PRGO	INC L
	INC D
;	LD A,D
;	CP #5B
;	JR NZ,$+4
;	LD D,#48

;	CP #49
;	JR NZ,$+4
;	LD D,#5C

	PUSH HL
	LD L,(hl)
PRN	LD H,8
PR1	ADD HL,HL
	ADD HL,HL
	JR NC,PR1
	INC E
	LD A,L
	LD (DE),A
	DEC E
	LD A,(DE)
	OR H
	LD (DE),A
	POP HL
	DJNZ PRGO
	POP HL
	POP DE
	POP BC
	LD A,C
	DEC A
	SUB 6
	JR NC,$+5
	ADD A,8
	INC E
	INC A
	LD C,A
	RET 

DEPKFNT	LD HL,FONT
		LD DE,FONTS
		LD C,0
DEPKFN0	LD B,8
DEPKFN1	PUSH HL
		LD A,8
DEPKFN2	RRC (hl)
		INC HL
		RLA 
		JR NC,DEPKFN2
		LD (DE),A
		INC DE
		POP HL
		DJNZ DEPKFN1
		DUP 5
		INC HL
		EDUP 
		DEC C
		JR NZ,DEPKFN0
		RET 

ISITST	DEC HL
		LD A,H
		INC HL
		INC A
		RET 

ISITEND	PUSH DE
		LD DE,(NOBYTE)
		OR A
		SBC HL,DE
		ADD HL,DE
		POP DE
		RET 

GETBYTE	PUSH BC
		PUSH HL
		LD A,H
		LD C,A
		OR 192
		LD H,A
		LD A,C
		RLCA 
		RLCA 
		AND 3
GETBYTA	ADD A,24
		LD BC,32765
		OUT (C),A
		LD A,(hl)
		POP HL
		POP BC
		RET

;		include	"uart_RW.asm"
;----------------------------------CUT HERE------------------------------------------

UART_DAT EQU 0xF8EF ;DAT и DLL одинаковые, так надо
UART_DLL EQU 0xF8EF 
UART_DLM EQU 0xF9EF 
UART_FCR EQU 0xFAEF 
UART_LCR EQU 0xFBEF 
UART_LSR EQU 0xFDEF 
RTC_REG EQU 0xDEF7 
RTC_DATA EQU 0xBEF7 


;инициализация
UART_INIT: 

	ld	bc,0xfbef       	;LCR
	ld	a,0x83
	out	(c),a
	ld	b,0xf8          	;DLL
	ld	de,2		;делитель 1 - 115200; 2 - 57600
	out	(c),e
	inc	b               	;DLM
	out	(c),d
	ld	b,0xfc          	;MCR
	ld	a,0x03
	out	(c),a
	dec	b               	;LCR
	ld	a,0x03
	out	(c),a

UART_FIFO_RESET

	ld	bc,0xfaef       	;FCR
	ld	a,0x07          	;FIFO reset
	out	(c),a
	ld	a,0x01
	out	(c),A
	ret

	
;На входе в HL буфер, куда читать пакет.
;лучше выключать прерывания на время приёмки. а то потеряем дату, и будет переполнение фифо

UART_READ:
	ld	de,$400			; количество попыток чтения из FIFO, на всяк случай, т.к. мы не знаем маркер конца
	call	UART_BUF_CHECK
	ld	bc,UART_DAT

.lp1
	dec	de
	ld	a,e
	or	d
	ret	z
	in	a,(c)			;Читаем байтик
	or	a
	jr	z,.lp1
	ld	(hl),a
	inc	hl
	cp	#0d
	jr	nz,.lp1
	call	UART_BUF_CHECK	
	in	a,(c)
	ld	(hl),a
	inc	hl	
	cp	#0a
	ret	z
	jr	.lp1

UART_BUF_CHECK
	push	bc
	push	de
	ld	d,100
	ld	b,#fd			;LSR check for emptyness
.lp2	dec	d
	jr	z,.lp3
	in	a,(c)
;					;ПОКА не проверяем на переполнение буфера!!!
;	bit	1,a			;проверяем на переполнение буфера
					;выход с ошибкой, в А неноль
;	ret	nz
	bit	0,a			;проверяем есть ли чего в буфере приёма
	jr	z,.lp2			;если буфер пустой то ждём
.lp3	pop	de
	pop	bc
	ret
	


UART_WRITE:
      ld	bc,0xfdef       	;LSR
_putch1:
	in	a,(c)	
	and	0x20
	jr	z,_putch1
	ld	a,(hl)
	or	a
	ret	z
	ld	b,0xf8			;DAT
	out	(c),a
	inc	hl
	jr	UART_WRITE
	
err_esp		db	"No ESP! ",0

 	ORG	#7B00
FONT
		INCBIN "42F.!C"
;		ENT

END

codeend

	emptytrd		"1term.trd"
;	savetrd		"1term.trd", "memlib.C", main, codeend-main
	savetrd		"1term.trd", "term.C", main, codeend-main
	
