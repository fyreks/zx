			DEVICE	ZXSPECTRUM128
;LAST UPDATE: 08.12.2015 savelij
codstart

SYSREG_EFF7	EQU 0XEFF7
SET_ADR		EQU 0XDFF7
RD_WR_DATA	EQU 0XBFF7
CMOS_ON		EQU 0X80
CMOS_OFF	EQU 0


AREP		DB 1				;задержка автоповтора
ADEL		DB 0				;счетчик автоповтора
LAST_PRESS	DB 0				;последний считанный код нажатой клавиши
MOD_KEY	DW 0				;+0 (reg E) режимы нажатых клавиш
						;+1 (reg D) состояние CAPS LOCK, NUM LOCK
BIT_KEYS	DB 0				;бит 7-нажата возвращаемая клавиша
						;    6-нажата функциональная клавиша F1-F11
						;    5-нажата спецклавиша CTRL,ALT,GUI,...
						;  4-0-номер функциональной клавиши (F1-F11=1-11)
LAST_KEY	DB 0				;код нажатой декодированной клавиши
EAREP

;[номера битов нажатых клавиш]
_BIT_KEY	EQU 7				;нажата какая-то клавиша
_BIT_FKEY	EQU 6				;нажата функциональная клавиша F1-F11
_BIT_MODKEY	EQU 5				;нажата спецклавиша (CTRL, SHIFT, ...)

;[маска битов нажатых клавиш]
_M_KEY		EQU 1<<_BIT_KEY			;нажата какая-то клавиша
_M_FKEY		EQU 1<<_BIT_FKEY	;нажата функциональная клавиша F1-F11
_M_MODKEY	EQU 1<<_BIT_MODKEY		;нажата спецклавиша  (CTRL, SHIFT, ...)

_NUM_AREP	EQU 20				;задержка автоповтора
_NUM_ADEL	EQU 3				;счетчик автоповтора

;[reg E номера битов нажатых клавиш]
REG_DE
;[reg E номера битов нажатых клавиш]
.B_R_GUI	EQU 7				;нажат правый GUI
.B_R_ALT	EQU 6				;нажат правый ALT
.B_R_CTRL	EQU 5				;нажат правый CTRL
.B_R_SHIFT	EQU 4				;нажат правый SHIFT
.B_L_GUI	EQU 3				;нажат левый GUI
.B_L_ALT	EQU 2				;нажат левый ALT
.B_L_CTRL	EQU 1				;нажат левый CTRL
.B_L_SHIFT	EQU 0				;нажат левый SHIFT
;[reg D номера битов нажатых клавиш]
.B_CAPSLOCK	EQU 7				;режим CAPS LOCK
.B_NUMLOCK	EQU 6				;режим NUM LOCK

.B_ONOFF_RS	EQU 4				;нажат переключатель RUS/LAT (SHIFT+CTRL)
.B_RUSLAT	EQU 3				;режим RUS/LAT
.B_EXTKEY	EQU 2				;нажата кнопка с доп кодом
.B_UNKEY	EQU 1				;какая-то кнопка отпущена
.B_PRESSKEY	EQU 0				;что-то было нажато
;[reg E маски битов установки нажатых клавиш]
.M_R_GUI	EQU 1<<.B_R_GUI			;нажат правый GUI
.M_R_ALT	EQU 1<<.B_R_ALT			;нажат правый ALT
.M_R_CTRL	EQU 1<<.B_R_CTRL		;нажат правый CTRL
.M_R_SHIFT	EQU 1<<.B_R_SHIFT		;нажат правый SHIFT
.M_L_GUI	EQU 1<<.B_L_GUI			;нажат левый GUI
.M_L_ALT	EQU 1<<.B_L_ALT			;нажат левый ALT
.M_L_CTRL	EQU 1<<.B_L_CTRL		;нажат левый CTRL
.M_L_SHIFT	EQU 1<<.B_L_SHIFT		;нажат левый SHIFT
;[reg D маски битов установки нажатых клавиш] 
.M_CAPSLOCK	EQU 1<<.B_CAPSLOCK		;режим CAPS LOCK
.M_NUMLOCK	EQU 1<<.B_NUMLOCK		;режим NUM LOCK

.M_ONOFF_RS	EQU 1<<.B_ONOFF_RS		;нажат переключатель RUS/LAT (SHIFT+CTRL)
.M_RUSLAT	EQU 1<<.B_RUSLAT		;режим RUS/LAT
.M_EXTKEY	EQU 1<<.B_EXTKEY		;нажата кнопка с доп кодом
.M_UNKEY	EQU 1<<.B_UNKEY			;какая-то кнопка отпущена
.M_PRESSKEY	EQU 1<<.B_PRESSKEY		;что-то было нажато

;[код считываемый с клавиатуры и не возвращаемый]
C_LR_ALT	EQU 0X11
C_L_SHIFT	EQU 0X12
C_LR_CTRL	EQU 0X14
C_L_GUI		EQU 0X1F
C_R_GUI		EQU 0X27
C_CAPSLOCK	EQU 0X58
C_R_SHIFT	EQU 0X59
C_NUMLOCK	EQU 0X77
ADD_EXT		EQU 0X80			;индикатор клавиши с доп. кодом
ADD_CODE	EQU 0XE0			;расширенный код
OFF_KEY		EQU 0XF0			;код отпущенной клавиши

__CTRL_A	EQU 0X01			;CTRL-A
__CTRL_B	EQU 0X02			;CTRL-B
__CTRL_C	EQU 0X03			;CTRL-C
__CTRL_D	EQU 0X04			;CTRL-D
__CTRL_E	EQU 0X05			;CTRL-E
__CTRL_F	EQU 0X06			;CTRL-F
__CTRL_G	EQU 0X07			;CTRL-G
__CTRL_H	EQU 0X08			;CTRL-H or BACKSPACE
__CTRL_I	EQU 0X09			;CTRL-I or TAB
__CTRL_J	EQU 0X0A			;CTRL-J
__CTRL_K	EQU 0X0B			;CTRL-K or HOME
__CTRL_L	EQU 0X0C			;CTRL-L
__CTRL_M	EQU 0X0D			;CTRL-M or RETURN(ENTER)
__CTRL_N	EQU 0X0E			;CTRL-N
__CTRL_O	EQU 0X0F			;CTRL-O
__CTRL_P	EQU 0X10			;CTRL-P
__CTRL_Q	EQU 0X11			;CTRL-Q
__CTRL_R	EQU 0X12			;CTRL-R or INSERT
__CTRL_S	EQU 0X13			;CTRL-S
__CTRL_T	EQU 0X14			;CTRL-T
__CTRL_U	EQU 0X15			;CTRL-U
__CTRL_V	EQU 0X16			;CTRL-V
__CTRL_W	EQU 0X17			;CTRL-W
__CTRL_X	EQU 0X18			;CTRL-X or END
__CTRL_Y	EQU 0X19			;CTRL-Y
__CTRL_Z	EQU 0X1A			;CTRL-Z
__CTRL_RS	EQU 0X1B			;CTRL-] or ESC
__CURSOR_R	EQU 0X1C			;CURSOR RIGHT
__CURSOR_L	EQU 0X1D			;CURSOR LEFT
__CURSOR_U	EQU 0X1E			;CURSOR UP
__CURSOR_D	EQU 0X1F			;CURSOR DOWN
__KDELETE	EQU 0X7F			;DELETE

__F1		EQU 0X01			;F1
__F2		EQU 0X02			;F2
__F3		EQU 0X03			;F3
__F4		EQU 0X04			;F4
__F5		EQU 0X05			;F5
__F6		EQU 0X06			;F6
__F7		EQU 0X07			;F7
__F8		EQU 0X08			;F8
__F9		EQU 0X09			;F9
__F10		EQU 0X0A			;F10
__F11		EQU 0X0B			;F11

;[соответствие считанных кодов] 
K_A		EQU 0X1C
K_B		EQU 0X32
K_C		EQU 0X21
K_D		EQU 0X23
K_E		EQU 0X24
K_F		EQU 0X2B
K_G		EQU 0X34
K_H		EQU 0X33
K_I		EQU 0X43
K_J		EQU 0X3B
K_K		EQU 0X42
K_L		EQU 0X4B
K_M		EQU 0X3A
K_N		EQU 0X31
K_O		EQU 0X44
K_P		EQU 0X4D
K_Q		EQU 0X15
K_R		EQU 0X2D
K_S		EQU 0X1B
K_T		EQU 0X2C
K_U		EQU 0X3C
K_V		EQU 0X2A
K_W		EQU 0X1D
K_X		EQU 0X22
K_Y		EQU 0X35
K_Z		EQU 0X1A
K_0		EQU 0X45
K_1		EQU 0X16
K_2		EQU 0X1E
K_3		EQU 0X26
K_4		EQU 0X25
K_5		EQU 0X2E
K_6		EQU 0X36
K_7		EQU 0X3D
K_8		EQU 0X3E
K_9		EQU 0X46
K_APOSTROF	EQU 0X0E
K_MINUS		EQU 0X4E
K_RAVNO		EQU 0X55
K_BSLASH	EQU 0X5D
K_BKSP		EQU 0X66
K_SPACE		EQU 0X29
K_TAB		EQU 0X0D
K_CAPSLOCK	EQU 0X58
K_LSHIFT	EQU 0X12
K_LCTRL		EQU 0X14
KX_LGUI		EQU 0X1F|ADD_EXT
K_LALT		EQU 0X11
K_RSHIFT	EQU 0X59
KX_RCTRL	EQU 0X14|ADD_EXT
KX_RGUI		EQU 0X27|ADD_EXT
KX_RALT		EQU 0X11|ADD_EXT
KX_APPS		EQU 0X2F|ADD_EXT
K_ENTER		EQU 0X5A
K_ESC		EQU 0X76
K_F1		EQU 0X05
K_F2		EQU 0X06
K_F3		EQU 0X04
K_F4		EQU 0X0C
K_F5		EQU 0X03
K_F6		EQU 0X0B
K_F7_OLD	EQU 0X83			;реальный возвращаемый код клавиши F7
K_F7		EQU 0X02			;считанный код 0х83 заменяется на код 2
K_F8		EQU 0X0A
K_F9		EQU 0X01
K_F10		EQU 0X09
K_F11		EQU 0X78
K_F12		EQU 0X07
K_QSKOBKAL	EQU 0X54
KX_INSERT	EQU 0X70|ADD_EXT
KX_HOME		EQU 0X6C|ADD_EXT
KX_PAGEUP	EQU 0X7D|ADD_EXT
KX_DELETE	EQU 0X71|ADD_EXT
KX_END		EQU 0X69|ADD_EXT
KX_PAGEDOWN	EQU 0X7A|ADD_EXT
KX_UARROW	EQU 0X75|ADD_EXT
KX_LARROW	EQU 0X6B|ADD_EXT
KX_DARROW	EQU 0X72|ADD_EXT
KX_RARROW	EQU 0X74|ADD_EXT
K_NUMLOCK	EQU 0X77
KX_KPDIV	EQU 0X4A|ADD_EXT
K_KPMUL		EQU 0X7C
K_KPMINUS	EQU 0X7B
K_KPPLUS	EQU 0X79
KX_KPENTER	EQU 0X5A|ADD_EXT
K_KPDOT		EQU 0X71
K_KP0		EQU 0X70
K_KP1		EQU 0X69
K_KP2		EQU 0X72
K_KP3		EQU 0X7A
K_KP4		EQU 0X6B
K_KP5		EQU 0X73
K_KP6		EQU 0X74
K_KP7		EQU 0X6C
K_KP8		EQU 0X75
K_KP9		EQU 0X7D
K_QSKOBKAR	EQU 0X5B
K_DOTZAP	EQU 0X4C
K_1KABYCH	EQU 0X52
K_ZAP		EQU 0X41
K_DOT		EQU 0X49
K_DIV		EQU 0X4A

;[коды независимые от режимов]
OB_KEYS		DB KX_INSERT,KX_DELETE,KX_HOME,KX_END,KX_PAGEUP,KX_PAGEDOWN
		DB K_TAB,K_ENTER,K_BKSP,KX_KPENTER,KX_KPDIV,K_KPMUL,K_KPMINUS
		DB K_KPPLUS,KX_APPS,KX_UARROW,KX_LARROW,KX_DARROW
		DB KX_RARROW,K_ESC,K_SPACE
EOB_KEYS
		DB " ",__CTRL_RS,__CURSOR_R,__CURSOR_D,__CURSOR_L,__CURSOR_U,0X00,"+-*/",__CTRL_M
		DB __CTRL_H,__CTRL_M,__CTRL_I,0X00,0X00,__CTRL_X,__CTRL_K,__KDELETE,__CTRL_R

FUNC_KEYS	DB K_F11,K_F10,K_F9,K_F8,K_F7,K_F6,K_F5,K_F4,K_F3,K_F2,K_F1
EFUNC_KEYS

;[коды в зависимости от состояния NUM LOCK]
NM_KEYS		DB K_KP0,K_KP1,K_KP2,K_KP3,K_KP4,K_KP5,K_KP6,K_KP7,K_KP8,K_KP9
		DB K_KPDOT
ENM_KEYS
		DB __KDELETE,0X00,__CURSOR_U,__CTRL_K,__CURSOR_R,0X00,__CURSOR_L,0X00,__CURSOR_D,__CTRL_X,__CTRL_R

NUM_ON		DB ".9876543210"

;[коды зависимые от режимов]
MD_KEYS		DB K_9,K_8,K_7,K_6,K_5,K_4,K_3,K_2,K_1,K_0

		DB K_Z,K_Y,K_X,K_W,K_V,K_U,K_T,K_S,K_R,K_Q,K_P,K_O
		DB K_N,K_M,K_L,K_K,K_J,K_I,K_H,K_G,K_F,K_E,K_D,K_C,K_B,K_A

		DB K_APOSTROF,K_MINUS,K_RAVNO,K_BSLASH,K_QSKOBKAL,K_QSKOBKAR
		DB K_DOTZAP,K_1KABYCH,K_ZAP,K_DOT,K_DIV
EMD_KEYS

;[нажатые клавиши с CTRL]
CTRL		DUP 5
			nop
			edup
		DB __CTRL_RS
		DUP 5
		NOP
		EDUP
		DB __CTRL_A,__CTRL_B,__CTRL_C,__CTRL_D,__CTRL_E,__CTRL_F,__CTRL_G,__CTRL_H,__CTRL_I,__CTRL_J
		DB __CTRL_K,__CTRL_L,__CTRL_M,__CTRL_N,__CTRL_O,__CTRL_P,__CTRL_Q,__CTRL_R,__CTRL_S,__CTRL_T
		DB __CTRL_U,__CTRL_V,__CTRL_W,__CTRL_X,__CTRL_Y,__CTRL_Z
		DB "0123456789"

;[нажатые клавиши без модификаторов в режиме LAT]
NO_LAT		DB "/.,';][\\=-`"
		DB "abcdefghijklmnopqrstuvwxyz"
		DB "0123456789"

;[нажатые клавиши без модификаторов в режиме RUS]
NO_RUS		DB ".юбэжъх\\=-ё"
		DB "фисвуапршолдьтщзйкыегмцчня"
		DB "0123456789"

;[нажатые клавиши с shift при выключенном CAPS LOCK в режиме RUS]
SHIFT_RUS_CL0	DB ",ЮБЭЖЪХ/+_Ё"
		DB "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ"
		DB ")!",'"',"№;%:?*("


;[нажатые клавиши с SHIFT при включенном CAPS LOCK в режиме RUS]
SHIFT_RUS_CL1	DB ",юбэжъх/+_ё"
		DB "фисвуапршолдьтщзйкыегмцчня"
		DB ")!",'"',"№;%:?*("

;[нажатые клавиши без SHIFT при включенном CAPS LOCK в режиме RUS]
SHIFT_RUS_CL2	DB ".ЮБЭЖЪХ\\=-Ё"
		DB "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ"
		DB "0123456789"

;[нажатые клавиши с SHIFT при выключенном CAPS LOCK в режиме LAT]
SHIFT_LAT_CL0	DB "?><",'"',":}{|+_~"
		DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		DB ")!@#$%^&*("

;[нажатые клавиши с SHIFT при включенном CAPS LOCK в режиме LAT]
SHIFT_LAT_CL1	DB "?><",'"',":}{|+_~"
		DB "abcdefghijklmnopqrstuvwxyz"
		DB ")!@#$%^&*("

;[нажатые клавиши без SHIFT при включенном CAPS LOCK в режиме LAT]
SHIFT_LAT_CL2	DB "/.,';][\\=-`"
		DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		DB "0123456789"

;B2-RUSLAT
;B1-SHIFT
;B0-CAPS LOCK
TABL_KEYS	DW NO_LAT
		DW SHIFT_LAT_CL2
		DW SHIFT_LAT_CL0
		DW SHIFT_LAT_CL1

		DW NO_RUS
		DW SHIFT_RUS_CL2
		DW SHIFT_RUS_CL0
		DW SHIFT_RUS_CL1

;[конверсия считанного кода в символ в зависимости от режима]
CONV_STD	LD HL,BIT_KEYS
		LD A,_M_MODKEY			;маскировка спецклавиш (CTRL, ALT, ...)
		AND (HL)
		LD (HL),A			;пока не определено что нажато -> ничего не нажато
		LD HL,MOD_KEY+1
		BIT REG_DE.B_PRESSKEY,(HL)	;что-то нажато?
		RET Z				;нет
		RES REG_DE.B_PRESSKEY,(HL)
		LD A,(LAST_PRESS)		;считанный код нажатой клавиши
		LD HL,FUNC_KEYS
		LD BC,EFUNC_KEYS-FUNC_KEYS
		CPIR				;проверка по кодам функциональных клавиш
		JR NZ,.CONVSTD6			;если нажата не функциональная клавиша, продолжаем
		INC C				;номер функциональной клавиши
		LD HL,MOD_KEY+1
		RES REG_DE.B_PRESSKEY,(HL)
		LD HL,BIT_KEYS
		LD A,(HL)
		OR _M_FKEY			;нажата функциональная клавиша
		OR C				;номер функциональной клавиши
		LD (HL),A
		RET

.CONVSTD6	LD HL,OB_KEYS
		LD BC,EOB_KEYS-OB_KEYS
		CPIR				;поиск в таблице кодов независимых от режима
		JR NZ,.CONVSTD1
		LD HL,EOB_KEYS
		JR .CONVSTD2

.CONVSTD1	
		AND	#ff 				; было -ADD_EXT!0XFF
		LD HL,NM_KEYS
		LD BC,ENM_KEYS-NM_KEYS
		CPIR				;поиск в таблицы для кодов свзянных с NUM LOCK
		JR NZ,.CONVSTD3
		LD HL,MOD_KEY+1
		BIT REG_DE.B_NUMLOCK,(HL)
		LD HL,ENM_KEYS
		JR Z,.CONVSTD2
		LD HL,NUM_ON
		JR .CONVSTD2

.CONVSTD3	LD HL,MD_KEYS
		LD BC,EMD_KEYS-MD_KEYS
		CPIR				;ищем считанный код в таблице
		LD DE,(MOD_KEY)
		LD A,REG_DE.M_R_CTRL|REG_DE.M_L_CTRL
		AND E				;нажат ли CTRL?
		LD HL,CTRL			;на случай если нажат CTRL
		JR NZ,.CONVSTD2			;CTRL нажат!
.CONVSTD4	LD A,D
		AND REG_DE.M_RUSLAT		;проверка и учет режима RUS/LAT
		RRCA
		LD L,A
		LD A,REG_DE.M_R_SHIFT|REG_DE.M_L_SHIFT
		AND E
		JR Z,.CONVSTD5			;никакой из SHIFT не нажат
		LD A,REG_DE.M_L_SHIFT<<1	;если нажат любой из SHIFT умножаем на 2 для таблицы
.CONVSTD5	OR L				;учитываем какой режим включен (RUS/LAT)
		ADD A,A
		LD E,A
		LD D,0
		LD HL,TABL_KEYS			;список адресов таблиц для разных режимов
		ADD HL,DE
		LD E,(HL)
		INC HL
		LD D,(HL)			;получили адрес таблицы откуда взять символ
		EX DE,HL
.CONVSTD2	ADD HL,BC
		LD A,(HL)			;получили код символа для возврата
		AND A
		RET Z				;если получили 0, то не возвращаем
		LD HL,BIT_KEYS
		SET _BIT_KEY,(HL)
		LD (LAST_KEY),A
		RET

;[опрос PS/2 клавиатуры]
;внутренние регистры
;D-биты состояния CAPS LOCK, NUM LOCK и временные биты отжатых клавиш и допкода
;E-биты невозвращаемых клавиш (CTRL, SHIFT, ALT, GUI)
;C-прочитанное значение из буфера клавиатуры
READ_KEYS	PUSH HL
		PUSH DE
		PUSH BC
		PUSH AF
		LD DE,(MOD_KEY)
.READ_NEXT	LD H,0XF0
		CALL CMOSREAD			;чтение байта из буфера клавиатуры
		LD C,A				;прочитанное значение
		AND A
		JP Z,.NO_RDKEY			;если 0, то ничего не нажато (буфер пуст)
		INC A
		CALL Z,RESET_KEYS		;если 0xFF, то инитим лог (буфер переполнен)
		JP Z,.SET_PRESS_KEY
		LD A,C
		CP ADD_CODE
		JR NZ,.CMP_OFF_KEY
		SET REG_DE.B_EXTKEY,D		;нажата кнопка с доп кодом
		JR .SET_PRESS_KEY

.CMP_OFF_KEY	CP OFF_KEY
		JR NZ,.CMP_ADD_KEY
		SET REG_DE.B_UNKEY,D		;какая-то кнопка отпущена
		JR .SET_PRESS_KEY

.CMP_ADD_KEY	LD HL,TBL_EXE_PRESS
		LD BC,TBL_EXEPRESS-TBL_EXE_PRESS
		CPIR				;проверка нажатой клавиши из списка
		JR NZ,.CMP_F7
		LD HL,TBL_EXEPRESS
		ADD HL,BC
		ADD HL,BC
		LD A,(HL)
		INC HL
		LD H,(HL)
		LD L,A				;HL=адрес кода нажатой клавиши
		PUSH HL
		LD HL,END_EXTKEY
		EX (SP),HL
		JP (HL)

.CMP_F7		LD C,A
		CP K_F7_OLD
		JR NZ,.CMP_BIT_EXT
		LD C,K_F7			;считанный код клавиши F7 меняем на код 2
.CMP_BIT_EXT	BIT REG_DE.B_EXTKEY,D
		JR Z,.PRESSED_KEY
		OR ADD_EXT			;бит 7 нажатой клавиши устанавливаем для клавиши с доп. кодом
		LD C,A
.PRESSED_KEY	BIT REG_DE.B_UNKEY,D
		RES REG_DE.B_UNKEY,D
		RES REG_DE.B_EXTKEY,D
		LD HL,AREP
		JR NZ,.NOPRESSED_KEY
;заносим в список нажатых клавиш
		LD (HL),_NUM_AREP		;AREP
		INC HL
		LD (HL),0			;ADEL
		INC HL
		LD (HL),C			;LAST_PRESS
		SET REG_DE.B_PRESSKEY,D
		JR .SET_PRESS_KEY

;удаляем из списка нажатых клавиш
.NOPRESSED_KEY	LD C,0
		LD (HL),C			;AREP
		INC HL
		LD (HL),C			;ADEL
		INC HL
		LD (HL),C			;LAST_PRESS
		RES REG_DE.B_PRESSKEY,D
.SET_PRESS_KEY	LD (MOD_KEY),DE			;сохранили текущие режимы
		CALL CONV_STD			;конверсия в возвращаемый код
		POP AF
		POP BC
		POP DE
		POP HL
		RET

.NO_RDKEY	LD A,(LAST_PRESS)
		AND A
		JR Z,.SET_PRESS_KEY
		LD HL,FUNC_KEYS
		LD BC,EFUNC_KEYS-FUNC_KEYS
		CPIR				;проверка по кодам функциональных клавиш
		JR Z,.SET_PRESS_KEY
		RES REG_DE.B_PRESSKEY,D
		LD HL,AREP
		LD A,(HL)
		DEC (HL)
		AND A
		JR NZ,.SET_PRESS_KEY
		LD (HL),A
		INC HL
		LD A,(HL)
		DEC (HL)
		AND A
		JR NZ,.SET_PRESS_KEY
		SET REG_DE.B_PRESSKEY,D
		LD (HL),_NUM_ADEL
		JR .SET_PRESS_KEY

TBL_EXE_PRESS	DB C_LR_ALT
		DB C_L_SHIFT
		DB C_LR_CTRL
		DB C_L_GUI
		DB C_R_GUI
		DB C_CAPSLOCK
		DB C_R_SHIFT
		DB C_NUMLOCK

TBL_EXEPRESS	DW EXE_NUMLOCK
		DW EXE_RSHIFT
		DW EXE_CAPSLOCK
		DW EXE_RGUI
		DW EXE_LGUI
		DW EXE_LRCTRL
		DW EXE_LSHIFT
		DW EXE_LRALT

END_EXTKEY	RES REG_DE.B_UNKEY,D
		RES REG_DE.B_EXTKEY,D
		LD A,REG_DE.M_R_CTRL|REG_DE.M_L_CTRL
		AND E
		JR Z,ENDEXTKEY1
		LD A,REG_DE.M_R_SHIFT|REG_DE.M_L_SHIFT
		AND E
		JR Z,ENDEXTKEY1
		BIT REG_DE.B_ONOFF_RS,D
		JR NZ,ENDEXTKEY1
		SET REG_DE.B_ONOFF_RS,D
		LD A,REG_DE.M_RUSLAT
		XOR D
		LD D,A
		JP READ_KEYS.NO_RDKEY

ENDEXTKEY1	RES REG_DE.B_ONOFF_RS,D
		JP READ_KEYS.SET_PRESS_KEY

EXE_LRALT	BIT REG_DE.B_UNKEY,D
		JR NZ,EXE_LRALT1
		BIT REG_DE.B_EXTKEY,D
		JR NZ,EXE_LRALT2
		SET REG_DE.B_L_ALT,E		;нажат левый ALT
		RET

EXE_LRALT2	SET REG_DE.B_R_ALT,E		;нажат правый ALT
		RET

EXE_LRALT1	BIT REG_DE.B_EXTKEY,D
		JR NZ,EXE_LRALT3
		RES REG_DE.B_L_ALT,E		;отпущен левый ALT
		RET

EXE_LRALT3	RES REG_DE.B_R_ALT,E		;отпущен правый ALT
		RET

EXE_LRCTRL	BIT REG_DE.B_UNKEY,D
		JR NZ,EXE_LRCTRL1
		BIT REG_DE.B_EXTKEY,D
		JR NZ,EXE_LRCTRL2
		SET REG_DE.B_L_CTRL,E		;нажат левый CTRL
		RET

EXE_LRCTRL2	SET REG_DE.B_R_CTRL,E		;нажат правый CTRL
		RET

EXE_LRCTRL1	BIT REG_DE.B_EXTKEY,D
		JR NZ,EXE_LRCTRL3
		RES REG_DE.B_L_CTRL,E		;отпущен левый CTRL
		RET

EXE_LRCTRL3	RES REG_DE.B_R_CTRL,E		;отпущен правый CTRL
		RET

EXE_LSHIFT	SET REG_DE.B_L_SHIFT,E		;нажат левый SHIFT
		BIT REG_DE.B_UNKEY,D
		RET Z
		RES REG_DE.B_L_SHIFT,E		;отпущен левый SHIFT
		RET

EXE_RSHIFT	SET REG_DE.B_R_SHIFT,E		;нажат правый SHIFT
		BIT REG_DE.B_UNKEY,D
		RET Z
		RES REG_DE.B_R_SHIFT,E		;отпущен правый SHIFT
		RET

EXE_RGUI	SET REG_DE.B_R_GUI,E		;нажат правый GUI
		BIT REG_DE.B_UNKEY,D
		RET Z
		RES REG_DE.B_R_GUI,E		;отпущен правый GUI
		RET

EXE_LGUI	SET REG_DE.B_L_GUI,E		;нажат левый GUI
		BIT REG_DE.B_UNKEY,D
		RET Z
		RES REG_DE.B_L_GUI,E		;отпущен левый GUI
		RET

EXE_NUMLOCK	BIT REG_DE.B_UNKEY,D		;нажат NUM LOCK
		RET NZ
		LD A,REG_DE.M_NUMLOCK
		XOR D				;инверсия режима
		LD D,A
		RET

;[изменение состояния CAPS LOCK]
EXE_CAPSLOCK	BIT REG_DE.B_UNKEY,D
		RET NZ
		PUSH HL
		LD H,0X0C
		CALL CMOSREAD
		LD A,2
		XOR L
		LD L,A
		PUSH AF
		CALL CMOSWRITE
		POP AF
		POP HL
		SET REG_DE.B_CAPSLOCK,D		;CAPS LOCK включен
		AND 2
		RET NZ
		RES REG_DE.B_CAPSLOCK,D		;CAPS LOCK выключен
		RET

;[настройка доступа к клавиатуре]
INIT_KEYS	LD HL,AREP
		LD BC,(EAREP-AREP)<<8
		LD (HL),C
		INC HL
		DJNZ $-2
		LD H,0X0C
		CALL CMOSREAD			;прочитали регистр 0x0C CMOS
		PUSH HL
		SET 0,L				;бит 0=1 сброс буфера клавиатуры
		CALL CMOSWRITE			;записали обратно
		LD HL,0XF002
		CALL CMOSWRITE			;включили доступ к буферу клавиатуры
		POP HL
		BIT 1,L				;проверка текущего состояния CAPS LOCK
		LD HL,MOD_KEY+1
		RES REG_DE.B_CAPSLOCK,(HL)	;выключено
		RET Z
		SET REG_DE.B_CAPSLOCK,(HL)	;включено
		RET

;[сброс буфера клавиатуры при переполнении]
RESET_KEYS	PUSH AF
		PUSH HL
		LD H,0X0C
		CALL CMOSREAD			;прочитали регистр 0x0C CMOS
		SET 0,L
		CALL CMOSWRITE
		LD HL,0XF002
		CALL CMOSWRITE			;включили доступ к буферу клавиатуры
		POP HL
		POP AF
		RET


;LAST UPDATE: 16.11.2014 savelij

;INPUT: H-CELL address
;	   L - DATA to write

CMOSWRITE
		CALL onCMOS
		LD A,H
		LD BC,SET_ADR
		OUT (C),A
		LD A,L
		LD BC,RD_WR_DATA
		OUT (C),A
offCMOS
		LD BC,SYSREG_EFF7
		LD A,CMOS_OFF
		OUT (C),A
		EI
		RET

onCMOS	
		DI
		LD BC,SYSREG_EFF7
		LD A,CMOS_ON
		OUT (C),A
		RET

;INPUT: H-CELL address
; L - DATA read (result)
CMOSREAD
		CALL onCMOS
		LD A,H
		LD BC,SET_ADR
		OUT (C),A
		LD BC,RD_WR_DATA
		IN A,(C)
		LD H,A
		CALL offCMOS
		LD A,H
		AND A
		RET
codend

;01234567890123456789012345678901234567890123456789012345678901234567890123456789
;┌───┐ ┌──┬──┬──┬──┐┌──┬──┬──┬──┐┌──┬───┬───┬───┐ ┌───┬───┬───┐			00
;│ESC│ │F1│F2│F3│F4││F5│F6│F7│F8││F9│F10│F11│F12│ │PRT│SCL│PAU│			01
;└───┘ └──┴──┴──┴──┘└──┴──┴──┴──┘└──┴───┴───┴───┘ └───┴───┴───┘			02
;┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬────┐ ┌───┬───┬───┐ ┌──┬──┬──┬──┐	03
;│ ~│ 1│ 2│ 3│ 4│ 5│ 6│ 7│ 8│ 9│ 0│ -│ =│ |│ BS │ │INS│HOM│PUp│ │NM│ /│ *│ -│	04
;├──┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴────┤ ├───┼───┼───┤ ├──┼──┼──┼──┤	05
;│ TAB│ Q│ W│ E│ R│ T│ Y│ U│ I│ O│ P│ [│ ]│     │ │DEL│END│PDn│ │ 7│ 8│ 9│  │	06
;├────┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴──┤ENTER│ └───┴───┴───┘ ├──┼──┼──┤ +│	07
;│CSLOCK│ A│ S│ D│ F│ G│ H│ J│ K│ L│ ;│ ' │     │               │ 4│ 5│ 6│  │	08
;├──────┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬┴─┬─┴─────┤     ┌───┐     ├──┼──┼──┼──┤	09
;│  SHIFT │ Z│ X│ C│ V│ B│ N│ M│ ,│ .│ /│ SHIFT │     │ UP│     │ 1│ 2│ 3│ E│	0A
;├──────┬─┴─┬┴──┼──┴──┴──┴──┼──┴┬─┴─┬┴──┴┬──────┤ ┌───┼───┼───┐ ├──┴──┼──┤ N│	0B
;│ CTRL │WIN│ALT│   SPACE   │ALT│WIN│MENU│ CTRL │ │ LF│DWN│RT │ │  0  │ .│ T│	0C
;└──────┴───┴───┴───────────┴───┴───┴────┴──────┘ └───┴───┴───┘ └─────┴──┴──┘	0D
;01234567890123456789012345678901234567890123456789012345678901234567890123456789

;========================ОДНОКОДОВЫЕ=========================  =====КОДОМ E0=====
;1C	A	45	0	04	F3	7D	KP 9	1F	LGUI
;32	B	16	1	0C	F4	5B	]	14	RCTRL	
;21	C	1E	2	03	F5	4C	;	27	RGUI
;23	D	26	3	0B	F6	52	'	11	RALT
;24	E	25	4	83	F7	41	,	2F	APPS
;2B	F	2E	5	0A	F8	49	.	70	INSERT
;34	G	36	6	01	F9	4A	/	6C	HOME
;33	H	3D	7	09	F10			7D	PG UP
;43	I	3E	8	78	F11			71	DELETE
;3B	J	46	9	07	F12			69	END
;42	K	0E	`	7E	SCROLL			7A	PG DN
;4B	L	4E	-	54	[			75	U ARROW
;3A	M	55	=	77	NUM			6B	L ARROW
;31	N	5D	\	7C	KP *			72	D ARROW
;44	O	66	BKSP	7B	KP -			74	R ARROW
;4D	P	29	SPACE	79	KP +			4A	KP /
;15	Q	0D	TAB	71	KP .			5A	KP ENTER
;2D	R	58	CAPS	70	KP 0
;1B	S	12	LSHIFT	69	KP 1
;2C	T	14	LCTRL	72	KP 2
;3C	U	11	LALT	7A	KP 3
;2A	V	59	RSHIFT	6B	KP 4
;1D	W	5A	ENTER	73	KP 5
;22	X	76	ESC	74	KP 6
;35	Y	05	F1	6C	KP 7
;1A	Z	06	F2	75	KP 8

	emptytrd	"2pckbd.trd"
;	savetrd	"1.trd", "memlib.C", main, codeend-main
	savetrd	"2pckbd.trd", "pckbd.C", codstart, codend-codstart