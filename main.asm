/*
 * main_test.asm
 *
 *  Created: 13/05/2019 14:55:15
 *   Author: Matthieu
 */ 
; file	wire1_temp2.asm		
; purpose Dallas 1-wire(R) temperature sensor interfacing: temperature
; module: M5, input port: PORTE
.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

/*
.macro SET_TMAX ; reg // permet de régler Tmax (ici dans le reg b0)
	
	in	a2,PIND		; read buttons
	out	PORTB,a2	; write result to LEDs

	sbis PIND,0  
	inc b0
	sbis PIND,1
	dec b0
.endmacro
*/
; === initialization (reset) ===
reset:		
	LDSP	RAMEND			; load stack pointer (SP)
	/*OUTI	DDRB,$ff		; make LEDs output
	rcall	wire1_init		; initialize 1-wire(R) interface
	rcall	lcd_init		; initialize LCD
	ldi b0, 0x14			; initialize Tmax = 20°C */
	rcall	ws2812b4_init	; initialize the LED matrix	
	rjmp	main

; ===== include local =========
/*.include "lcd.asm"			; include LCD driver routines
.include "printf.asm"		; include formatted printing routines
.include "wire1.asm"		; include Dallas 1-wire(R) routines*/
.include "matrix_driver1.asm" ; include driver for LED matrix


; === main program ===
main:
	/*rcall	wire1_reset			; send a reset pulse
	CA	wire1_write, skipROM	; skip ROM identification
	CA	wire1_write, convertT	; initiate temp conversion
	WAIT_MS	750					; wait 750 msec
	
	rcall	lcd_home			; place cursor to home position
	rcall	wire1_reset			; send a reset pulse
	CA	wire1_write, skipROM
	CA	wire1_write, readScratchpad	
	rcall	wire1_read			; read temperature LSB
	mov	c0,a0
	rcall	wire1_read			; read temperature MSB
	mov	a1,a0
	mov	a0,c0

	SET_TMAX b0*/
	
	
	// LED MATRIX //
	
	rcall ws2812b4_reset
    WS2812b4_MAIN 0x32, 0xCD, 0x32
	
	
	// Affichage sur LCD//
	/*
	rcall LCD_clear
	PRINTF	LCD
	.db		"temp=",FFRAC2+FSIGN,a,4,$42,"C ",CR,0 ; écriture de la température ambiante
	rcall LCD_LF ; passe à la ligne 2 du lcd
	PRINTF LCD
	.db "a=", FBIN,a,0	
	PRINTF	LCD
	.db "Tmax=", FDEC,b,"C ",0	*/				   ;écriture de la Tmax set par l'utilisateur
	rjmp	main
