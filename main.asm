/*
 * main.asm
 *
 *  Created: 13/05/2019 14:55:15
 *   Author: Duret Matthieu, Jaramillo Claudio
 */ 
; main file	pour station météo

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

.org 0						;as soon as the microcontroller starts go to reset
	rjmp  reset

.org 8
	rjmp int_reset			;internal reset

.org OVF0addr		;timer overflow 0 interrupt vector
	rjmp overflow0

; === interrupt service routines ===
overflow0: ;generate sound when Tmax is reached
	INVP	PORTE,SPEAKER
	reti

int_reset: ;reset the machine
		rjmp reset
		reti

; === initialisation (reset) ===
reset:		
	LDSP	RAMEND			; load stack pointer (SP)
	OUTI	DDRB,0xff		; make LEDs output
	OUTI	ASSR, (0<<AS0)  ; internal clock
	OUTI	TCCR0,3			; CS = 3
	OUTI	DDRD, 0x00
	OUTI	EIMSK,8			; enable INT3
	OUTI	EICRB,0			; reset du système en appuyant sur le bonton 3
	sei						; set global interrupts
	rcall	wire1_init		; initialize 1-wire(R) interface
	rcall	lcd_init		; initialize LCD
	rcall	ws2812b4_init	; initialize the LED matrix	
	sbi		DDRE, SPEAKER	; make pin speaker an output
	ldi b0, 30				; initialize Tmax = 30°C 
	rjmp	main

; ===== include local ======
.include "matrix_driver1.asm" ; include driver for LED matrix
.include "lcd.asm"			; include LCD driver routines
.include "printf.asm"		; include formatted printing routines
.include "wire1.asm"		; include Dallas 1-wire(R) routines

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

	// partie 1 : on regroupe les bits qui nous intéressent dans le registre qui contient la T AMB - utilisation de la pile par sécurité

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
	andi b0, 0b01111111 ; Masquage du bit 7
	cpse b0,a3
	rjmp compare_1
	
	OUTI	TIMSK, (1<<TOIE0)	; buzz si la température dépasse


	
	cp b0,a3					;test if we're over the maximum temperature
	brmi matrix_alarm

	matrix_alarm :
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
		
	

//=======================================================================================	
	// LED MATRIX //

	;sous_routine pour affecter une couleur à la LED en fonction de la température
	compare_1 : 
		cp b0,a3 ;test if we're over the maximum temperature
		brmi matrix_alarm
		cpi a3, 27	;compare a3 to temperature 27
		brmi compare_2 ;if negative branch to next routine
		ldi zl, low(2*colour_orange) ;point to table
		ldi zh, high(2*colour_orange)
		lpm
		mov c1,r0	; read low byte from table
		adiw zl,1	; increment pointer z
		lpm
		mov c2, r0  ;repeat
		adiw zl,1
		lpm
		mov c3, r0
		OUTI	TIMSK, (0<<TOIE0)
		rjmp iluminate

	compare_2 : 
		cp b0,a3 ;test if we're over the maximum temperature
		brmi matrix_alarm
		cpi a3, 25	;compare a3 to temperature 25
		brmi compare_3
		ldi zl, low(2*colour_yellowish) ;point to table
		ldi zh, high(2*colour_yellowish)
		lpm
		mov c1,r0	; read low byte from table
		adiw zl,1	; increment pointer z
		lpm
		mov c2, r0
		adiw zl,1
		lpm
		mov c3, r0
		OUTI	TIMSK, (0<<TOIE0)
		rjmp iluminate

	compare_3 : 
		cp b0,a3 ;test if we're over the maximum temperature
		brmi matrix_alarm
		cpi a3, 24	;compare a3 to temperature 24
		brmi compare_4 ;if negative branch to next routine
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
		OUTI	TIMSK, (0<<TOIE0)
		rjmp iluminate

	compare_4 : 
		cp b0,a3 ;test if we're over the maximum temperature
		brmi matrix_alarm
		cpi a3, 22	;compare a3 to temperature 22
		brmi default_colour ;if negative branch to next routine
		ldi zl, low(2*colour_blue2) ;point to table
		ldi zh, high(2*colour_blue2)
		lpm
		mov c1,r0	; read low byte from table
		adiw zl,1	; increment pointer z
		lpm
		mov c2, r0
		adiw zl,1
		lpm
		mov c3, r0
		OUTI	TIMSK, (0<<TOIE0)
		rjmp iluminate


	default_colour : 
		ldi zl, low(2*colour_blue1) ;point to table
		ldi zh, high(2*colour_blue1)
		lpm
		mov c1,r0	; read low byte from table
		adiw zl,1	; increment pointer z
		lpm
		mov c2, r0
		adiw zl,1
		lpm
		mov c3, r0
		OUTI	TIMSK, (0<<TOIE0)
		rjmp iluminate

	iluminate : 
		WS2812b4_MAIN c1,c2,c3  ; put specified colour in matrix LED
//=====================================================================

	// Affichage sur LCD//
	
	rcall LCD_clear 	;clear LCD screen
	PRINTF	LCD			;print info on LCD
	.db		"temp=",FFRAC2+FSIGN,a,4,$42,"C ",CR,0 ; écriture de la température ambiante
		
	
	rcall LCD_LF ; passe à la ligne 2 du lcd
	PRINTF	LCD
	.db "Tmax=", FDEC,b,"C ",0	;écriture de la Tmax set par l'utilisateur
	
	
	
	rjmp	main

; ===== LUT for LED colours ===== -> colour coding is GRB
colour_blue1 : .db 0x0f, 0x09, 0x0f		;used for temps below 22
colour_blue2 : .db 0x0b, 0x06, 0x0f		;used for temps between 22 and 24
colour_green : .db 0x0f, 0x00, 0x00		;used for temps between 24 and 25
colour_yellowish : .db 0x06, 0x0c, 0x00 ;used for temps between 25 and 27 
colour_orange : .db 0x03,0x0f, 0x00		;used for temps above 27 
colour_red : .db 0x00,0x0f, 0x00		;used for alarm

