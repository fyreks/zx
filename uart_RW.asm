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
	call	UART_BUF_READ
	ld	bc,UART_DAT

.lp1
	dec	de
	ld	a,e
	or	d
	ret	z
	in	a,(c)			;Читаем байтик
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
	ld	b,#fd			;LSR check for emptyness
.lp2	in	a,(c)
;					;ПОКА не проверяем на переполнение буфера!!!
;	bit	1,a			;проверяем на переполнение буфера
					;выход с ошибкой, в А неноль
;	ret	nz
	bit	0,a			;проверяем есть ли чего в буфере приёма
	jr	z,UART_READ_WAIT	;если буфер пустой то ждём
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
