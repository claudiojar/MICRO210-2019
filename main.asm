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

.org 0
	rjmp  reset

; === initialization (reset) ===
reset:		
	LDSP	RAMEND			; load stack pointer (SP)
	OUTI	DDRB,0xff		; make LEDs output
	rcall	wire1_init		; initialize 1-wire(R) interface
	rcall	lcd_init		; initialize LCD
	rcall	ws2812b4_init	; initialize the LED matrix	
	;sbi		DDRE, SPEAKER	; make pin speaker an output
	ldi b0, 0x14		; initialize Tmax = 20°C (0x14)
	rjmp	main

; ===== include local ======
.include "matrix_driver1.asm" ; include driver for LED matrix
.include "lcd.asm"			; include LCD driver routines
.include "printf.asm"		; include formatted printing routines
.include "wire1.asm"		; include Dallas 1-wire(R) routines
;.include "sound.asm"




; === main program ===
main:
	rcall	wire1_reset			; send a reset pulse
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
	mov	a1,a0					; a1 = MSB	
	mov	a0,c0					; a0 = LSB

	

	//SET TMAX//

	in	a2,PIND		; read buttons
	out	PORTB,a2	; write result to LEDs

	sbis PIND,0  
	inc b0
	sbis PIND,1
	dec b0

	// COMPARE TMAX / T AMBIENTE //

	// partie 1 : on regroupe les bits qui nous intéressent dans le registre qui contient la T AMB

	push w 
	clr w
	add w,a0
	andi w, 0b11110000			; masquage		
	swap w 
	clr a3						; par sécurité
	add a3,w
	clr w
	add w,a1
	andi w, 0b00000111			; masquage
	swap w
	add a3,w
	clr w 
	pop w

	// partie 2: comparer TMAX / TAMB (copiée dans b3)
	andi b0, 0b01111111 ; BEAUF 
	/*cpse b0,a3
	rjmp PC+3
	cbi PORTE,SPEAKER
	WAIT_US 100*/

//=======================================================================================	
	// LED MATRIX //
	
	/*;rcall ws2812b4_reset ; activate LED Matrix 
	ldi a3, 30*/

	;sous_routine pour affecter une couleur à la LED en fonction de la température
	compare_1 : 
		cpi a3, 27	;compare a3 to temperature 25
		brmi compare_2 ;if negative branch to next routine
		ldi zl, low(2*colour_red) ;point to table
		ldi zh, high(2*colour_red)
		lpm
		mov c1,r0	; read low byte from table
		adiw zl,1	; increment pointer z
		lpm
		mov c2, r0
		adiw zl,1
		lpm
		mov c3, r0
		rjmp iluminate

	compare_2 : 
		cpi a3, 26	;compare a3 to temperature 25
		brmi default_colour ;if negative branch to next routine
		ldi zl, low(2*colour_green) ;point to table
		ldi zh, high(2*colour_green)
		lpm
		mov c1,r0	; read low byte from table
		adiw zl,1	; increment pointer z
		lpm
		mov c2, r0
		adiw zl,1
		lpm
		mov c3, r0
		rjmp iluminate
	
	default_colour : 
		ldi zl, low(2*colour_blue) ;point to table
		ldi zh, high(2*colour_blue)
		lpm
		mov c1,r0	; read low byte from table
		adiw zl,1	; increment pointer z
		lpm
		mov c2, r0
		adiw zl,1
		lpm
		mov c3, r0
		rjmp iluminate

	iluminate : 
		WS2812b4_MAIN c1,c2,c3  ; put specified colour in matrix LED
//=====================================================================

	// Affichage sur LCD//
	
	rcall LCD_clear
	PRINTF	LCD
	.db		"temp=",FFRAC2+FSIGN,a,4,$42,"C ",CR,0 ; écriture de la température ambiante
		
	clr c0      // technique de sioux
	add c0,a3
	rcall LCD_LF ; passe à la ligne 2 du lcd
	PRINTF	LCD
	;.db "Tmax=", FDEC,b,"C ",0						   ;écriture de la Tmax set par l'utilisateur
	.db " a3 = ", FDEC,c,0
	
	
	rjmp	main

	; ===== LUT for LED colours =====
colour_blue : .db 0x01, 0x01, 0xff ; GRB
colour_green : .db 0xff, 0x01, 0x01
colour_red : .db 0x01,0xff, 0x01

