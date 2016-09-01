UART_DAT EQU 0xF8EF ;DAT и DLL одинаковые, так надо
UART_DLL EQU 0xF8EF 
UART_DLM EQU 0xF9EF 
UART_FCR EQU 0xFAEF 
UART_LCR EQU 0xFBEF 
UART_LSR EQU 0xFDEF 
RTC_REG  EQU 0xDEF7 
RTC_DATA EQU 0xBEF7 
; ВНИМАНИЕ!!!
; СКОРОСТЬ УАРТ поднял до 115200. делитель с 2х поменял на 1! По инструкции делитель
; должен быть = 5!!! ДимкаМ - поясни!
	
;инициализация
UART_INIT: 
	LD BC,UART_LCR	;переключаем DAT в режим DLL
	LD A,%10000000
	OUT (C),A
	LD BC,UART_DLL	;настраивам делитель скорости(115200/n) в baseconf не выше 56700
	LD A,1		;т.е. делить будем на два 115200/2=57600
	OUT (C),A		;закидываем младший байт делителя
	LD BC,UART_DLM
	ld a,0			;и старший ноль соответственно
	OUT (C),A
	LD BC,UART_LCR	;переключаем DLL в режим регистра данных
	LD A,3			;заодно 1 стопбит и без контроля чётности и без управления потоком
	OUT (C),A
UART_FIFO_RESET:
	ld bc,UART_FCR	;сбрасываем буферы
	ld a,7
	out (c),a
	ret
	
;приём DE-байтов в по адресу HL. на выходе в A: ноль-ОК, неноль-ошибка
;лучше выключать прерывания на время приёмки. а то просрём дату, и будед переполнение фифо
UART_READ:					;кагбы можно слать данные с ПЦ, будем ждать
;		ld a,d
;		or e
;		ret z				;читать больше нинадо, выход с ОК, в А ноль
		ld bc,UART_LSR		;читаем статус
UART_READ_WAIT:
		exx				;мое корявое дополнение для прерывания чтения из компорта тк
		dec	bc			;может не остановиться и зациклиться
		ld	a,c
		or	b
		ret z
		exx
		in a,(c)		
		bit 1,a			;проверяем на переполнение буфера
		ret nz			;выход с ошибкой, в А неноль
		bit 0,a			;проверяем естьли чего в буфере приёма
		jr z,UART_READ_WAIT	;если буфер пустой то ждём
		ld bc,UART_DAT		;читаем байт
		in a,(c)
		cp	10		; тут acid пытался сделать проверку байта на канец пакета от ЕСП. Но не сработало
		jr	nz,.skp1
		ld	(hl),a
		inc	hl
		ld	a,13
		ld	(hl),a
		ret				;выход тк данных больше не будет

.skp1		ld	(hl),a
		inc hl
;		dec	de
		jr UART_READ
	
;отправка DE-байтов начиная с адреса HL. на выходе в A: ноль-ОК, неноль-ошибка
UART_WRITE:	;кагбы ПЦ уже должен быть готов принимать дату
;		ld a,d
;		or e
;		ret z	;слать больше нинадо, выход с ОК, в А ноль
		ld bc,UART_LSR	;читаем статус
UART_WRITE_WAIT:
		in a,(c)		
		bit 6,a			;ждём отправки предыдущего байта
		jr z,UART_WRITE_WAIT	;если буфер непустой то ждём
		ld bc,UART_DAT	;отсылаем байт
		ld a,(hl)
		inc hl
		out (c),a
		cp	10
		ret	z
;		dec de
		jr UART_WRITE
