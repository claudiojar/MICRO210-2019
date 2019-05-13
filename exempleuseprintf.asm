; file	useprintf.asm   target ATmega128L-4MHz-STK300			
; purpose display formatted string	
.include "macros.asm"	
.include "definitions.asm"

reset:
	LDSP	RAMEND		; load stack pointer
	OUTI	DDRB,0xff	; make portB output
	rcall	LCD_init	; initialize LCD
	rjmp	main
.include "lcd.asm"
.include "printf.asm"

main:	
	in	a0,PIND		; read switches
	out	PORTB,a0	; write to LED
	com	a0		; invert a0
	
	rcall	LCD_clear
	PRINTF	LCD
	.db "a=", FDEC,a,0
	WAIT_MS	100
	rjmp 	main