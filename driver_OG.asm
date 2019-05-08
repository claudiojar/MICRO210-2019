<pre><div class="text_to_html">; file	ws2812b_4MHz_demo03_S.asm   target ATmega128L-4MHz-STK300
; purpose send data to ws2812b using 4 MHz MCU and standard I/O port
;         display four basic colors on first four LEDs
; usage: ws2812 on PORTD (data, bit 1)
; warnings: 1/2 timings of pulses in the macros are sensitive
;			2/2 intensity of LEDs is high, thus keep intensities
;				within the range 0x00-0x0f, and do not look into
;				LEDs
; 20180926 AxS

.include "macros.asm"	; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; WS2812b4_WR0	; macro ; arg: void; used: void
; purpose: write an active-high zero-pulse to PD1
; PORTD is assumed only used for the purpose
.macro	WS2812b4_WR0
	clr	u
	sbi PORTD, 1
	out PORTD, u
	nop
	nop
	;nop
	;nop
.endm

; WS2812b4_WR1	; macro ; arg: void; used: void
; purpose: write an active-high one-pulse to PD1
.macro	WS2812b4_WR1
	sbi PORTD, 1
	nop
	nop
	cbi PORTD, 1
	;nop
	;nop
.endm

.org 0

reset:
	LDSP	RAMEND			; Load Stack Pointer (SP)
	rcall	ws2812b4_init		; initialize 

main:
	ldi a0,0x00		;zero-intensity, pixel is off
	ldi a1,0x00
	ldi a2,0x00
	rcall ws2812b4_byte3wr

	ldi a0,0x0f		;low-intensity pure green
	ldi a1,0x00
	ldi a2,0x00
	rcall ws2812b4_byte3wr

	ldi a0,0x00		;low-intensity pure red
	ldi a1,0x0f
	ldi a2,0x00
	rcall ws2812b4_byte3wr

	ldi a0,0x00		;low-intensity pure blue
	ldi a1,0x00
	ldi a2,0x0f	
	rcall ws2812b4_byte3wr

	rcall ws2812b4_reset

end:
	rjmp end


; ws2812b4_init		; arg: void; used: r16 (w)
; purpose: initialize AVR to support ws2812b
ws2812b4_init:
	OUTI	DDRD,0x02
ret

; ws2812b4_byte3wr	; arg: a0,a1,a2 ; used: r16 (w)
; purpose: write contents of a0,a1,a2 (24 bit) into ws2812, 1 LED configuring
;     GBR color coding, LSB first
ws2812b4_byte3wr:

	ldi w,8
ws2b3_starta0:
	sbrc a0,7
	rjmp	ws2b3w1
	WS2812b4_WR0		
	rjmp	ws2b3_nexta0
ws2b3w1:
	WS2812b4_WR1
ws2b3_nexta0:
	lsl a0
	dec	w
	brne ws2b3_starta0

	ldi w,8
ws2b3_starta1:
	sbrc a1,7
	rjmp	ws2b3w1a1
	WS2812b4_WR0		
	rjmp	ws2b3_nexta1
ws2b3w1a1:
	WS2812b4_WR1
ws2b3_nexta1:
	lsl a1
	dec	w
	brne ws2b3_starta1

	ldi w,8
ws2b3_starta2:
	sbrc a2,7
	rjmp	ws2b3w1a2
	WS2812b4_WR0		
	rjmp	ws2b3_nexta2
ws2b3w1a2:
	WS2812b4_WR1
ws2b3_nexta2:
	lsl a2
	dec	w
	brne ws2b3_starta2
	
ret

; ws2812b4_reset	; arg: void; used: r16 (w)
; purpose: reset pulse, configuration becomes effective
ws2812b4_reset:
	cbi PORTD, 1
	WAIT_US	50 	; 50 us are required, NO smaller works
ret</div></pre>