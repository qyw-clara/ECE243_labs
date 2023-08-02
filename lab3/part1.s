.global _start
_start:	
		//MOV	R4, #BIT_CODES
		LDR	R5, =0xFF200020
		LDR	R6, =0xFF200050
		MOV R1, #0
PRESS:
		LDR R7, [R6]
		CMP R7, #0
		BEQ	PRESS		
		MOV R8, R7
RELEASE:
		LDR	R7,[R6]
		CMP R7, #0
		BNE	RELEASE
		CMP R8, #1	//0001 key0
		BEQ	ZERO
		CMP R8, #2	//0010 key1
		BEQ	INC
		CMP	R8, #4	//0100 key2 
		BEQ	DEC
		CMP R8, #8	//1000 key3
		BEQ BLANK
ZERO:
		MOV R1, #0
		B DISPLAY
INC:	
		CMP R1, #9
		ADDLT R1, #1
		B DISPLAY
DEC:
		CMP	R1, #0
		SUBGT R1, #1
		B	DISPLAY		
BLANK:
		MOV R9, #0
		STR R9, [R5]
PRESS_A:
		LDR	R7, [R6]
		CMP R7, #0
		BEQ	PRESS_A
		MOV R8, #1
		BL 	RELEASE
		B	DISPLAY
DISPLAY:
		MOV	R4, #BIT_CODES
		ADD R4, R1
		LDRB R0, [R4]
		STR	R0, [R5]
		B PRESS
		
		

	
BIT_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
           .byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
		   .skip 2