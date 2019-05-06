/*
 * AsmFile1.asm
 *
 *  Created: 06/05/2019 12:16:37
 *   Author: mduret
 */ 

 .include "macros.asm"
 .include "definitions.asm"

 ; INITIALISATION

 reset:
		LDSP RAMEND
		rcall wire1_init
		rjmp main


.include "wire1.asm"

main:
	rcall wire1_reset
	ldi a0, 0xf0
	rcall wire1_write
	WAIT_MS 10
	rjmp main


