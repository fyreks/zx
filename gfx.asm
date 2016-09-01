
	DEVICE	ZXSPECTRUM128

	org	$c000
main
	ret					; standart descriptor of zx library
	db	"graphics library"	; name
	dw	1				; $ver
	dw	codeend-main		; library size
	dw	init				; init procedure if needed
	dw	global			; main entry point address
	dw	0				; relocable size
	dw	0				; relocable table

init	di
	ld	bc,$EFF7
	xor	a
	out	(c),a
	out	($FE),a
	ld	a,3
	ld	bc,$77
	out	(c),a
	ld	hl,$4000
	ld	de,$4001
	ld	bc,6144
	ld	(hl),l
	ldir
	ld	a,4
	ld	(hl),a
	ld	bc,767
	ldir
	ld	hl,font+("A"*8)
	ld	de,$4000
	ld	b,7
.loop	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	d
	djnz	.loop
	ei
	ret

font	include "6x8_1.asm"

	emptytrd	"1.trd"
	savetrd	"1.trd", "memlib.C", main