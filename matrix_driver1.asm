; file	ws2812b_4MHz_demo03_S.asm   target ATmegb228L-4MHz-STK300
; purpose send data to ws2812b using 4 MHz MCU and standard I/O port
;         display four basic colors on first four LEDs
; usage: ws2812 on PORTD (data, bit 1)
; warnings: 1/2 timings of pulses in the macros are sensitive
;			2/2 intensity of LEDs is high, thus keep intensities
;				within the range 0x00-0x0f, and do not look into
;				LEDs
; 20180926 AxS

;.include "macros.asm"	; include macro definitions
;.include "definitions.asm" ; include register/constant definitions

; WS2812b4_WR0	; macro ; arg: void; used: void
; purpose: write an active-high zero-pulse to PD1
; PORTD is assumed only used for the purpose
.macro	WS2812b4_WR0
	clr	u
	sbi PORTE, 3
	out PORTE, u
	nop
	nop
	;nop
	;nop
.endmacro

; WS2812b4_WR1	; macro ; arg: void; used: void
; purpose: write an active-high one-pulse to PD1
.macro	WS2812b4_WR1
	sbi PORTE, 3
	nop
	nop
	cbi PORTE, 3
	;nop
	;nop
.endmacro

; WS2812b4_MAIN	; macro 
; purpose: push colour to matrix
.macro WS2812b4_MAIN
;8 LEDS 1
	
	mov b1,@0		;pixel with a given value 
	mov b2,@1
	mov b3,@2
	rcall ws2812b4_byte3wr
	/*
	ldi b1,@0		;pixel with a given value 
	ldi b2,@1
	ldi b3,@2
	rcall ws2812b4_byte3wr

	ldi b1,@0		;pixel with a given value 
	ldi b2,@1
	ldi b3,@2
	rcall ws2812b4_byte3wr
	
	ldi b1,@0		;pixel with a given value 
	ldi b2,@1
	ldi b3,@2
	rcall ws2812b4_byte3wr
	
	ldi b1,@0		;pixel with a given value 
	ldi b2,@1
	ldi b3,@2
	rcall ws2812b4_byte3wr
	
	ldi b1,@0		;pixel with a given value 
	ldi b2,@1
	ldi b3,@2
	rcall ws2812b4_byte3wr
	
	ldi b1,@0		;pixel with a given value 
	ldi b2,@1
	ldi b3,@2
	rcall ws2812b4_byte3wr
;8 LEDS 1
*/
	rcall ws2812b4_reset
.endm


; ws2812b4_init		; arg: void; used: r16 (w)
; purpose: initialize AVR to support ws2812b
ws2812b4_init:
	OUTI	DDRE,0x08
ret

; ws2812b4_byte3wr	; arg: b1,b2,b3 ; used: r16 (w)
; purpose: write contents of b1,b2,b3 (24 bit) into ws2812, 1 LED configuring
;     GBR color coding, LSB first
ws2812b4_byte3wr:

		ldi w,8
	ws2b3_startb1:
		sbrc b1,7
		rjmp	ws2b3w1
		WS2812b4_WR0		
		rjmp	ws2b3_nextb1
	ws2b3w1:
		WS2812b4_WR1
	ws2b3_nextb1:
		lsl b1
		dec	w
		brne ws2b3_startb1

		ldi w,8
	ws2b3_startb2:
		sbrc b2,7
		rjmp	ws2b3w1b2
		WS2812b4_WR0		
		rjmp	ws2b3_nextb2
	ws2b3w1b2:
		WS2812b4_WR1
	ws2b3_nextb2:
		lsl b2
		dec	w
		brne ws2b3_startb2

		ldi w,8
	ws2b3_startb3:
		sbrc b3,7
		rjmp	ws2b3w1b3
		WS2812b4_WR0		
		rjmp	ws2b3_nextb3
	ws2b3w1b3:
		WS2812b4_WR1
	ws2b3_nextb3:
		lsl b3
		dec	w
		brne ws2b3_startb3
ret

; ws2812b4_reset	; arg: void; used: r16 (w)
; purpose: reset pulse, configuration becomes effective
ws2812b4_reset:
	cbi PORTE, 3
	WAIT_US	50 	; 50 us are required, NO smaller works
ret
