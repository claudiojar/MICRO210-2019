.include "macros.asm"
.include "definitions.asm"

			

reset:
	LDSP	RAMEND			; load stack pointer SP
	OUTI	DDRB,$ff		; make LEDs output
	rcall LCD_init			; intialize LCD
	ldi b0, 0x14			; initialize Tmax
	rjmp	main
.include "lcd.asm"
.include "printf.asm"




main:
	
	in	a0,PIND		; read buttons
	out	PORTB,a0	; write result to LEDs
	

	sbis PIND,0  
	inc b0
	sbis PIND,1
	dec b0

	// affichage sur LCD//

	rcall	LCD_clear
	PRINTF	LCD
	.db "a0 =", FBIN,a,0
	rcall LCD_LF ; passe à la ligne 2 du lcd
	PRINTF	LCD
	.db "Tmax=", FDEC,b,0
	WAIT_MS	100
	rjmp 	main