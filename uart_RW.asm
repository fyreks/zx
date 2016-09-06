	
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
	ld	de,1			;делитель 1 - 115200; 2 - 57600
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
.clfifo:
	ld	b,0xfd          	;LSR
	in	a,(c)
	and	0x01	
	ret	z
	ld	b,0xf8          	;DAT
	in	a,(c)
	jr	.clfifo
	
;приём DE-байтов в по адресу HL. на выходе в A: ноль-ОК, неноль-ошибка
;лучше выключать прерывания на время приёмки. а то просрём дату, и будед переполнение фифо

UART_READ:
	dec	de
	ld	a,d
	or	e
	ret	z			;читать больше нинадо, выход с ОК, в А ноль
	ld	bc,UART_LSR		;читаем статус

UART_READ_WAIT:

	in	a,(c)		
	and	1
	ret	z
;	bit	1,a			;проверяем на переполнение буфера
					;выход с ошибкой, в А неноль
;	ret	nz
;	bit	0,a			;проверяем естьли чего в буфере приёма
;	jr	z,UART_READ		;если буфер пустой то ждём
	ld	bc,UART_DAT		;читаем байт
	in	a,(c)
	ld	(hl),a
	inc	hl
	cp	10
	ret	z

	jr	UART_READ
	
;отправка. на выходе в A: ноль-ОК, не нуль - ошибка

UART_WRITE:
      ld	bc,0xfdef       ;LSR
_putch1:
	in	a,(c)	
	and	0x20
	jr	z,_putch1
	ld	b,0xf8		;DAT
	ld	a,(hl)
	out	(c),a
	cp	13
	ret	z
	inc	hl
	jr	UART_WRITE
