          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV R3, #TEST_NUM   // load the data word ...
		  MOV R5, #0	//initialize result register 
		  MOV R6, #0
		  MOV R7, #0
START:
		  LDR R1, [R3]        // into R1
		  
		  CMP R1, #0
		  BEQ DISPLAY
		  
		  BL ONES	//find longest one
		  CMP R5, R0
		  MOVLT R5, R0
		  LDR R1, [R3]
		  
		  BL ZEROS	//find longest zero
		  CMP R6, R0
		  MOVLT R6, R0
		  LDR R1, [R3], #4
		  
		  BL ALTERNATE  //find longest alternate
		  CMP R7, R0
		  MOVLT R7, R0
		  
		  B START
		  		  
		  
ONES:	  MOV R0, #0          // R0 will hold the result
ONE_LOOP: CMP R1, #0          // loop until the data contains no more 1's
          BEQ ONE_END             
          LSR R2, R1, #1      // perform SHIFT, followed by AND
          AND R1, R1, R2      
          ADD R0, #1          // count the string length so far
          B ONE_LOOP 		  //两段重复代码，合二为一
ONE_END:  MOV PC, LR	
		  
		  
ZEROS:      MOV R0, #0  		// R0 will hold the result
		    MVN R1, R1
ZERO_LOOP:  CMP R1, #0
		    BEQ ZERO_END
            LSR R2, R1, #1      // perform SHIFT, followed by AND
            AND R1, R1, R2      
            ADD R0, #1          // count the string length so far
		    B ZERO_LOOP
		  
ZERO_END:	MOV PC, LR


ALTERNATE:  MOV R0, #0
			LDR R4, =0x55555555	// 010101010101
			EOR	R1, R4
			PUSH {R1,LR}
			BL ONES //find the longest 10101010
			POP {R1}
			
			PUSH {R0}
			BL ZEROS //find the longest 01010101
			MOV R1,R0
			POP {R0}
			
			CMP R0, R1
			MOVLT R0, R1
			POP {PC}                         


/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            MOV     R0, R5          // display R5 on HEX1-HEX0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #8			//move bit code to the right palce
            ORR     R4, R0			//move bit code to the end of R0(combination of bit code)
            
			MOV	R0, R6				// display R6 on HEX2-HEX3
			BL	DIVIDE
			MOV	R9, R1				
			BL	SEG7_CODE
			LSL R0, #16
			ORR R4, R0				// save bit code
			MOV R0, R9				// retrieve the tens digit, get bit code
			BL	SEG7_CODE
			LSL	R0, #24
			ORR	R4, R0
			
            STR R4, [R8]        // display the numbers from R6 and R5
			
            LDR R10, =0xFF200030 // base address of HEX5-HEX4
  			MOV	R0, R7			// display R7 on HEX4-HEX5
			BL	DIVIDE
			MOV	R9, R1
			BL	SEG7_CODE
			
			MOV	R4, R0
			MOV	R0, R9
			BL	SEG7_CODE
			LSL	R0, #8
			ORR	R4, R0
			
            STR	R4, [R10]        // display the number from R7
			B	END
			
DIVIDE:     
			MOV    R2, #0
CONT:       CMP    R0, #10
            BLT    DIV_END
            SUB    R0, #10
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR


/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit patterm to be written to the HEX display
 */

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

END:      B END             


BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

TEST_NUM: .word 0x103fe00f
		  .word 0x7f05007e 
		  .word 0x1f00001d 
		  .word 0x560fff07
		  .word 0x0000000a 
		  .word 0xffffffff 
		  .word 0x567bdd78 
		  .word 0x9146abcd
		  .word 0x4501231f 
		  .word 0x450abd1f 
		  .word 0x679af31c 
		  .word 0x00000001 
		  .word 0x00000000

          .end          

