.global _start
_start:
		MOV R5, #BIT_CODES
		LDR	R6, =0xFF200050
		LDR	R7, =0xFF200020
		MOV	R4, #0
START:	LDR	R8, [R6, #0xC]
		CMP	R8, #0
		BNE	STOP
		B	DO_DELAY
LIMIT:	CMP	R4, #99
		MOVGT R4, #0
		CMP	R4, #0
		MOVLT R4, #0
		B DISPLAY

STOP:	STR R8, [R6, #0xC]
LOOP_S:	LDR R8, [R6, #0xC]
		CMP R8, #0
		BEQ LOOP_S
		STR R8, [R6, #0xC]
		B	LIMIT

DO_DELAY:	LDR	R9, =200000000	//=500000	
SUB_LOOP:	SUBS R9, #1
			BNE	SUB_LOOP
			B	LIMIT

DISPLAY:	MOV R0, R4
			BL	DIVIDE_10
			ADD R10, R5, R0
			LDRB R11, [R10]
			MOV R12, R11
			
			ADD	R10, R5, R1
			LDRB R11, [R10]
			LSL	R11, #8
			ORR R12, R11
			STR	R12, [R7]
			
			ADD	R4, #1
			B START
			
			
DIVIDE_10:	MOV R1, #0
CONT:		CMP R0, #10
			BLT DIV_END
			SUB R0, #10
			ADD R1, #1
			B CONT
DIV_END:	MOV PC, LR	// R1: quotient; R0: remainder	
			
	
BIT_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
           .byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
		   .skip 2