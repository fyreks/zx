	DEVICE	ZXSPECTRUM128

	org	$8000
	
screenaddr	EQU	$4000
scrsize		EQU	6144
INK		EQU	$29
BORDER		EQU	5
main
	ret						; standart descriptor of zx library - 29 bytes (#1D)
	db	"graphics library"			; name
	db	1,0					; $ver
	dw	codeend-main			; library size
	dw	init					; init procedure if needed
	dw	global				; main entry point address
	dw	0					; relocable size
	dw	0					; relocable table
;----------------------------------------------------------------
; main funcitons:
; - type text;
; - plot a dot;
; - draw a primitives (lines, circles, fill-up objects, etc);
; - copy blocks;
; - etc;
; USAGE:
; A - subroutine number, any other params are given in exact subroutine descriptor and in .doc files for each library
;
; 0 - print string (DE - pointer to the text string, finished by $FF; USE ESC code ($1B) to set coords two bytes)
; 1 - putc	(print character) AF' consist ASCII character. You have to setup coords each time you call this subroutine
; 2 - plot subroutine (DE - y,x coords; PUSH xx on stack - pixel color)
; 3 - line subroutine (DE' - starting coords(x,y); DE - finish coords(x,y))
; 4 - circle subroutine (store 2 bytes in temp_var - radius in pixels; DE - center coords)
; 5 - setup border&ink color
; 6 - clear screen
; 7 - clear an area (DE' - coords starting from; DE - x size; push xx - y size)
; 8 - setup new current coordinates, stored in (scrpos) variable
; 9 - moveup whole screen
; 10 - move down whole screen
; 11 - move an area

; 				TEST block
test
	di
	call	UART_INIT
	ld	hl,esp_init		;ATE0
	call	UART_WRITE
	
	ld	hl,buffer
	call	UART_READ

	push	hl
	call	UART_FIFO_RESET	
	ld	hl,esp_ip			;AT+GMR
	call	UART_WRITE

	pop	hl
	call	UART_READ
	call	UART_READ

	push	hl
	call	UART_FIFO_RESET	
	ld	hl,esp_myip		;AT+CIFSR
	call	UART_WRITE

	pop	hl

	call	UART_READ
	call	UART_READ


	push	hl
	call	UART_FIFO_RESET	;AT+CIPSTART...
	ld	hl,esp_con		
	call	UART_WRITE

	pop	hl
	call	UART_READ
	call	UART_READ
	call	UART_READ

	push	hl
	call	UART_FIFO_RESET	
	ld	hl,esp_list
	call	UART_WRITE

	pop	hl
	call	UART_READ
	call	UART_READ
	call	UART_READ

	push	hl

	call	UART_FIFO_RESET	
	ld	hl,esp_send
	call	UART_WRITE

	pop	hl
	call	UART_READ
	call	UART_READ
	call	UART_READ

	call	UART_FIFO_RESET	
	call	UART_READ
	call	UART_READ
	call	UART_READ
	call	UART_READ
	call	UART_READ
	call	UART_READ
	call	UART_READ
	call	UART_READ
	call	UART_READ
	call	UART_READ
	call	UART_READ
	ei
	halt
	halt
	di
	call	UART_READ

	ld	a,#ff
	ld	(hl),a
	ei

	call	init
	ld	a,6			; CLS screen
	call	global

;	ld	de,#405f
;	ld	a,7
;	push	af
;	ld	a,2			;TEST plot
;	call	global

	ld	de,text
	xor	a			; Welcome text output
	call	global

;	ld	de,c_coords
;	ld	a,8
;	call	global

;	ld	de,esp_init
;	xor	a
;	call	global
	
;	call	parse

here
	ld	de,buffer
	xor	a
	jp	global
	
wait10
;	ld	b,2
	ei
.zz	halt
;	djnz	.zz
	di
	ret
	
;	ld	de,c_coords
;	ld	a,8
;	call	global
	
;	ld	de,esp_init
;	ld	a,(de)
;	ex	af,af'
;	ld	a,1
;	call	global
;	call	incord

;	ld	de,esp_init+1
;	ld	a,(de)
;	ex	af,af'
;	ld	a,1
;	call	global
;	call	incord
	
;	ld	de,buffer
;	ld	a,(de)
;	ex	af,af'
;	ld	a,1
;	call	global
;	call	incord
	
;	ld	de,buffer+1
;	ld	a,(de)
;	ex	af,af'
;	ld	a,1
;	jp	global

;incord	
;	ld	hl,c_coords+1
;	ld	a,(hl)
;	inc	a
;	ld	(hl),a
;	ld	de,c_coords
;	ld	a,8
;	jp	global

;			END OF TEST BLOCK

init
		di
		ld	bc,$EFF7			; setup zx standart screen
		xor	a
		out	(c),a
		ld	a,3					; select zx standart screen
		ld	bc,$77
		out	(c),a
		ei
		ret
global
		ld	hl,subtbl			; subroutines table
		or	a
		jr	z,.skp1
		ld	b,0
		ld	c,a
.lp1		inc	hl
		inc	hl
		dec	a
		jr	nz,.lp1
.skp1		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		push	bc
		pop		hl
		jp	(hl)
	
cls
		ld	hl,screenaddr			; clear screen
		ld	de,screenaddr+1
		ld	bc,scrsize
		ld	(hl),l
		ldir
		ld	a,BORDER
		out	($FE),a				; border color = 0
		ld	a,INK					; INK color is green, PAPER is black
		ld	(hl),a
		ld	bc,767	
		ldir
		ret
	
puts
;
;	Эта часть кода - она должна не зависить от выбранного экрана, для этого в область переменных введем проверку основного экрана
;	что позволит использовать вывод с помощью драйвера конкретного экрана
;	как реализовать - если в области переменных флаг "zx_scr" не 0, то через core открываем, например, 16c.drv
;	где есть свои процедуры расчета адреса точки (байта, итп), вывода на экран байта, точки, рисование линий.
;	в остальных случаях используется стандартные функции из этой библиотеки
;	фактически, драйвера - дублируют функции библиотек
;	
;		ld	a,(zx_scr)
;		or	a
;		jr	z,.usezx
;		ld	hl,usr_scr			;user screen driver address initialized by the core while included new driver to the system
;		ld	c,(hl)
;		inc	hl
;		ld	b,(hl)
;		push	bc
;		pop	hl
;		ld	a,puts				;here type string proc selected
;		jp	(hl)				;execute it in exact screen driver
;.usezx

.looptxt
		ld	a,(de)
		cp	#ff
		ret	z
		cp	$1b					; if ESC seq. than setup coords
		jr	nz,.skp2
								; X, Y coords given in pixels.
		inc	de
		ld	a,(de)
		ld	c,a
		inc	de
		ld	a,(de)
		ld	b,a
		call	get_coords_char
		inc	de		
		ld	a,(de)				; get next byte to printout


.skp2
		cp	$20
		jr	nz,.skp3
		call	inc_coords
		inc	de
		jr	.looptxt
.skp3		ld	a,(de)
		cp	#0d
		jr	nz.skp0d
		ld	hl,(curpos)
		call	inc_y_attr
		ld	a,(de)
.skp0d		inc	de
		ld	hl,(curpx)
		ld	b,h
		ld	c,l
		call	get_coords_char
		ld	h,0
		ld	l,a
		add	hl,hl
		add	hl,hl
		add	hl,hl

		ld	bc,font
		add	hl,bc
		push	de
		call	put_c
		call	inc_coords
		pop	de
		jr	.looptxt

putc		ex	af,af'
		cp	$20			; put character - single on a screen. A' - ASCII character
		jr	nz,.skp4
		ret
.skp4
		ld	h,0
		ld	l,a
		add	hl,hl
		add	hl,hl
		add	hl,hl


		ld	bc,font
		add	hl,bc


put_c
		ld	de,(scrpos)
		
		ld	b,8
.loop		ld	a,(hl)
		ld	(de),a
		inc	hl
		inc	d
		djnz	.loop
		ret

plot		ld	l,d
		ld	h,0
		add	hl,hl
		ld	bc,ytable
		add	hl,bc
		ld	a,(hl)
		ld	c,a
		inc	hl
		ld	a,(hl)
		ld	b,a
		ld	a,e
		srl	a
		srl	a
		srl	a
		ld	l,a
		ld	h,0
		dup	4
		add	hl,hl
		edup
		push	bc
		ld	bc,xtable
		add	hl,bc
		ld	c,(hl)
		ld	b,0
		ld	a,e
		and	7
		rla
;		dec	a
		ld	e,a
		ld	d,0
		add	hl,de
		inc	hl
		ld	a,(hl)
		pop	hl
		add	hl,bc
		or	(hl)
		ld	(hl),a
		
		;... here comes color setup procedure
		pop	hl
		pop	bc
		push	hl
		
		ret

inc_coords
		
		ld	hl,(curpos)
		inc	l
		ld	a,l
		cp	#20
		jr	nz,.lp1
inc_y_attr	ld	l,0
		inc	h
		ld	a,h
		cp	24
		jr	nz,.lp1
		ld	h,0
.lp1		ld	(curpos),hl


		ld		a,l
		add		a,a
		add		a,a
		add		a,a
		ld		l,a
		ld		a,h
		add		a,a
		add		a,a
		add		a,a
		LD		H,A
		ld		(curpx),hl
		ret


get_coords_char

; Get screen address 
; B = Y pixel position 
; C = X pixel position 
; Returns address in HL 

;Get_Pixel_Address: 

	LD 		A,B			; Calculate Y2,Y1,Y0 
      	AND 		%00000111	 	; Mask out unwanted bits 
      	OR 		%01000000 		; Set base address of screen 
      	LD		H,A 			; Store in H 
      	LD 		A,B			; Calculate Y7,Y6 
	RRA 					; Shift to position 
      	RRA 
      	RRA 
      	AND 		%00011000 		; Mask out unwanted bits 
      	OR 		H 			; OR with Y2,Y1,Y0 
      	LD 		H,A 			; Store in H 
	LD 		A,B 			; Calculate Y5,Y4,Y3 
      	RLA 					; Shift to position 
      	RLA 
      	AND 		%11100000 		; Mask out unwanted bits 
      	LD		L,A 			; Store in L
      	LD 		A,C 			; Calculate X4,X3,X2,X1,X0 
      	RRA					; Shift into position 
      	RRA
      	RRA 
      	AND		%00011111 		; Mask out unwanted bits 
      	OR 		L			; OR with Y5,Y4,Y3 
      	LD 		L,A			; Store in L
	ld		(scrpos),hl
      	RET

		
;parse
;		ld	hl,buffer
;		ld	de,buffer2
;.stparse	ld	a,(hl)
;		inc	hl
;		cp	13
;		ret	z
;		cp	"<"
;		jr	nz,.skp1
;
;		nop			;here comes real parser
;
;;		ld	a,(hl)
;;		or	4		; case up
;;		some bla bla for links
;
;.skp1		ld	a,(hl)
;		inc	hl
;		cp	">"
;		jr	nz,.skp1
;.skp2		ldi
;		ld	a,(hl)
;		cp	"<"
;		jr	nz,.skp2
;		ld	a,32
;		ld	(de),a 
;		jr	.stparse



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
	ld	b,0xf8		;DAT
	ld	a,(hl)
	or	a
	ret	z
	out	(c),a
	inc	hl
	jr	UART_WRITE


		
text		db	$1B,0,0,"Franky's ESP Wi-Fi, $ver:0.01",$1b,22*8,0,"enter AT commands. Some times works WELL",$1b,2*8,0,">", #ff
curpos		dw	0
curpx		dw	0
scrpos		dw	screenaddr
subtbl		dw	puts,putc,plot,0,0,0,cls,0,get_coords_char
c_coords	db	0,0
ytable		include	"ytab.asm"
xtable		include	"xtab.asm"
font		include "6x8_1.asm"

esp_init	db	"ATE0",0x0d,0x0a,0
esp_ip		db	'AT',0x0d,0x0a,0
esp_myip	db	"AT",0X0D,0X0A,0
esp_con		db	'AT+CIPSTART="TCP","kalin.io",80',0x0d,0x0a,0
esp_list	db	"AT+CIPSEND=32",$0d,$0a,0
esp_send	db	"GET / HTTP/1.1",13,10
		db	"Host: kalin.io",0x0d,0x0a,0 ;32 bytes
buffer		block	4096,0x20
;buffer2	block	2048,0x20

		display	"data SIZE:",/A,buffer-esp_init
		display	"buffer addr: ",/A,buffer
		display	"text placement",/A,here+1
		display	"start test here: ", /A, test
codeend
	emptytrd		"1.trd"
;	savetrd		"1.trd", "memlib.C", main, codeend-main
	savetrd		"1.trd", "typist.C", main, codeend-main
