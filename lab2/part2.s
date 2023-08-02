/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R1, #TEST_NUM   // load the data word ...
		  MOV 	  R5, #0		  //initialize R5
START:
		  LDR     R3, [R1], #4       // into R3
		  CMP 	  R3, #0
		  BEQ	  END
		  BL 	  ONES			//find the longest satring of 1 in each word
		  CMP 	  R5, R0
		  MOVLT	  R5, R0
		  B 	  START



ONES:
          MOV     R0, #0          // R0 will hold the result
LOOP:     CMP     R3, #0          // loop until the data contains no more 1's
          BEQ     LEND             
          LSR     R2, R3, #1      // perform SHIFT, followed by AND
          AND     R3, R3, R2      
          ADD     R0, #1          // count the string length so far
          B       LOOP            

LEND:     MOV 	  PC, LR

END:      B       END             

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
