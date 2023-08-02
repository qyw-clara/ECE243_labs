/* Program that converts a binary number to decimal */
           
           .text               // executable code follows
           .global _start
_start:
            MOV    R4, #N
            MOV    R5, #Digits  // R5 points to the decimal digits storage location
            LDR    R4, [R4]     // R4 holds N
            MOV    R0, R4       // parameter for DIVIDE goes in R0
			CMP	   R0, #1 //should divide by 1
			MOVGE  R6, #1
			CMP    R0, #10 //should divide by 10
			MOVGE  R6, #10
			CMP	   R0, #100 //should divide by 100
			MOVGE  R6, #100
			CMP    R0, #1000 //should divide by 1000
			MOVGE  R6, #1000
			BL     DIVIDE
			STRB   R11, [R5, #3]
			STRB   R10, [R5, #2]
            STRB   R9, [R5, #1] // Tens digit is now in R1
            STRB   R8, [R5]     // Ones digit is in R0
END:        B      END

DIVIDE:		
			MOV R7, LR//有用吗？
			
			BL DIVISION10 //divisor is 1
			MOV R8, R0 
			CMP R6, #1
			MOVEQ PC, R7
			MOV R0, R1
			
			BL DIVISION10 //divisor is 10
			MOV R9, R0 
			CMP R6, #10
			MOVEQ PC, R7
			MOV R0, R1
			
			BL DIVISION10 //divisor is 100
			MOV R10, R0 
			CMP R6, #100
			MOVEQ PC, R7
			MOV R0, R1			
			
			BL DIVISION10 //divisor is 1000
			MOV R11, R0 
			MOV PC, R7
			
/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0 */
DIVISION10:     
			MOV    R2, #0
CONT:       CMP    R0, #10
            BLT    DIV_END
            SUB    R0, #10
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR

N:          .word  0         // the decimal number to be converted
Digits:     .space 4          // storage space for the decimal digits

            .end
