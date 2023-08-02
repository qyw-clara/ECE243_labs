/* Program that counts consecutive 1's */

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
		  BEQ END
		  
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
			LDR R4, =0x55555555	// 1010101010101010101010101010101
			EOR	R1, R1, R4
			PUSH {R1,LR} //store return address in stack
			BL ONES 
			POP {R1}
			
			PUSH {R0}
			BL ZEROS 
			MOV R1,R0
			POP {R0}
			
			CMP R0, R1
			MOVLT R0, R1 //R0 stores result
			POP {PC}
			


END:      B END             

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
