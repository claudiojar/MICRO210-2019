; file	speaker1.asm   target ATmega128L-4MHz-STK300
; purpose fixed frequency sound through piezo
; module: M2, output port: PORTE
.include "macros.asm"
.include "definitions.asm"

reset:
	LDSP	RAMEND				; load stack pointer SP
	OUTI	DDRB,$ff				; make LEDs output
	sbi	DDRE,SPEAKER				; make pin SPEAKER an output

main:
	sbi	PORTE,SPEAKER
	WAIT_US					; insert delay here

	cbi	PORTE,SPEAKER
	WAIT_US					; insert delay here
	rjmp	main