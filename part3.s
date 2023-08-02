/* Program that finds the largest number in a list of integers	*/
            
            .text                   // executable code follows
            .global _start                  
_start:                             
            MOV     R4, #RESULT     // R4 points to result location
            LDR     R0, [R4, #4]    // R0 holds the number of elements in the list
            MOV     R1, #NUMBERS    // R1 points to the start of the list
			LDR		R2, [R1]
            BL      LARGEST          
            STR     R0, [R4]        // R0 holds the subroutine return value

END:        B       END             

/* Subroutine to find the largest integer in a list
 * Parameters: R0 has the number of elements in the list
 *             R1 has the address of the start of the list
 			   R2 has the largest value in the list
			   R3 has the next number in the list
 * Returns: R0 returns the largest item in the list */
 			
LARGEST:      			
			SUBS 	R0, #1
			BEQ 	DONE
			LDR 	R3, [R1,#4]!
			CMP 	R3, R2
			BLE		LARGEST
			MOV 	R2, R3
			B 		LARGEST
			
DONE:
			MOV R0, R2
			BX 	LR

RESULT:     .word   0           
N:          .word   7           // number of entries in the list
NUMBERS:    .word   9, 15, 3, 6  // the data
            .word   1, 7, 2                 

            .end                            
