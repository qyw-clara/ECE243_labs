.global _start
_start:
	
	.global _start
_start:
	
               .equ      EDGE_TRIGGERED,    0x1
               .equ      LEVEL_SENSITIVE,   0x0
               .equ      CPU0,              0x01    // bit-mask; bit 0 represents cpu0
               .equ      ENABLE,            0x1

               .equ      KEY0,              0b0001
               .equ      KEY1,              0b0010
               .equ      KEY2,              0b0100
               .equ      KEY3,              0b1000

               .equ      IRQ_MODE,          0b10010
               .equ      SVC_MODE,          0b10011

               .equ      INT_ENABLE,        0b01000000
               .equ      INT_DISABLE,       0b11000000

/*********************************************************************************
 * Initialize the exception vector table
 ********************************************************************************/
                .section .vectors, "ax"

                B        _start             // reset vector
                .word    0                  // undefined instruction vector
                .word    0                  // software interrrupt vector
                .word    0                  // aborted prefetch vector
                .word    0                  // aborted data vector
                .word    0                  // unused vector
                B        IRQ_HANDLER        // IRQ interrupt vector
                .word    0                  // FIQ interrupt vector

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly code. The program 
 * responds to interrupts from a timer and the pushbutton KEYs in the FPGA.
 *
 * The interrupt service routine for the timer increments a counter that is shown
 * on the red lights LEDR by the main program. The counter can be stopped/run by 
 * pressing any of the KEYs.
 ********************************************************************************/
                .text
                .global  _start
_start:                                         
/* Set up stack pointers for IRQ and SVC processor modes */
				MOV	R1, #0b11010010			// interrupts masked, MODE = IRQ
				MSR	CPSR_c, R1				// change to IRQ mode
				LDR	SP, =0x40000           	// set IRQ stack pointer
				
				MOV	R1, #0b11010011			// interrupts masked, MODE = SVC
				MSR	CPSR_c, R1				// change to supervisor mode
				LDR	SP, =0x20000			
				
                BL       CONFIG_GIC         // configure the ARM generic
                                              // interrupt controlle				
                BL       CONFIG_PRIV_TIMER  // configure A9 Private Timer
                BL       CONFIG_KEYS        // configure the pushbutton
                                              // KEYs port
/* Enable IRQ interrupts in the ARM processor */
				MOV	R2, #0b01010011
				MSR	CPSR_c, R2
                LDR      R5, =0xFF200000    // LEDR base address
LOOP:                                          
                LDR      R3, COUNT          // global variable
                STR      R3, [R5]           // write to the LEDR lights
                B        LOOP                
          

/* Global variables */
                .global  COUNT
COUNT:          .word    0x0                  // used by timer
                .global  RUN
RUN:            .word    0x1                  // initial value to increment COUNT
SPEED:			.global SPEED
				.word 5000000

/*--- IRQ ---------------------------------------------------------------------*/
IRQ_HANDLER:
                PUSH {R0-R12, LR}
				
				LDR	R0, =0xFFFEC100
				LDR	R1, [R0, #0xC]
				CMP	R1, #73
				BLEQ	KEY_ISR
				CMP	R1, #29
				BLEQ	PRIV_TIMER_ISR	
EXIT_IRQ:
				STR	R1, [R0, #0x10]
				
				POP {R0-R12, LR}
                SUBS     PC, LR, #4

/****************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine toggles the RUN global variable.
 ***************************************************************************************/
                .global  KEY_ISR
KEY_ISR:        
                PUSH {R0-R12, LR}
				LDR R0, =0xFF200050
				LDR	R1,	[R0, #0xC]
				
				CMP	R1, #1  //KEY0
				BLEQ	KEY0_ISR
				CMP	R1, #2
				BLEQ	KEY1_ISR //KEY1
				CMP	R1, #4
				BLEQ KEY2_ISR	//KEY2
				
				MOV	R2, #0xF
				STR R2, [R0, #0xC]
				
				POP {R0-R12, LR}
                MOV      PC, LR
				
KEY0_ISR:			
				PUSH {R1,R2}
				LDR	R1, =RUN
				LDR	R2, [R1]
				EOR	R2, #1
				STR	R2, [R1]
				
				POP {R1,R2} 
				MOV PC, LR
				
KEY1_ISR:			
				PUSH {R0-R2}
				LDR R0, =0xFFFEC600
				MOV	R1, #0b0110
				LDR R1,[R0, #8] //set E bit 0 to stop the timer 
				LDR	R2, [R0]
				LSR	R2, #1 // count/2 -> rate*2
				STR	R2, [R0]
				
				MOV	R2, #0b111
				STR	R2, [R0, #8] // set E bit to 1 and restart the timer
				
				POP {R0-R2}
				MOV      PC, LR


KEY2_ISR:			
				PUSH {R0-R2}
				LDR R0, =0xFFFEC600
				MOV	R1, #0b0110
				LDR R1,[R0, #8] //set E bit 0 to stop the timer 
				LDR	R2, [R0]
				LSL	R2, #1 // count*2 -> rate/2
				STR	R2, [R0]
				
				MOV	R2, #0b111
				STR	R2, [R0, #8] // set E bit to 1 and restart the timer
				
				POP {R0-R2}
				MOV      PC, LR

/******************************************************************************
 * A9 Private Timer interrupt service routine
 *                                                                          
 * This code toggles performs the operation COUNT = COUNT + RUN
 *****************************************************************************/
                .global    TIMER_ISR
PRIV_TIMER_ISR:
                PUSH {R0-R12, LR}
				
				LDR	R0, =0xFFFEC600
				LDR	R1, =RUN
				LDR	R2, [R1]
				LDR	R3, =COUNT
				LDR	R4, [R3]
				CMP	R2, #1
				ADDEQ R4, #1
				STREQ R4, [R3]
				
				MOV R5, #1
				STR	R5, [R0, #0xC]	
				
				POP {R0-R12, LR}
                MOV      PC, LR

/* Configure the A9 Private Timer to create interrupts at 0.25 second intervals */
CONFIG_PRIV_TIMER:                             
                PUSH {R0-R12, LR}

				LDR R0, =0xFFFEC600
				LDR	R1, =SPEED//5*10^6
				LDR	R1,[R1]
				STR	R1, [R0]
				
				MOV	R2, #0b111
				STR	R2, [R0, #8]
DELAY_LOOP:		LDR	R3, [R0, #0xC]
				CMP	R3, #0
				BEQ	DELAY_LOOP
				
				POP {R0-R12, LR}
                MOV      PC, LR
/* Configure the pushbutton KEYS to generate interrupts */
CONFIG_KEYS:                                    
                PUSH {R0-R12, LR}
				
				LDR	R0, =0xFF200050
				MOV	R1, #0xF
				STR R1, [R0, #0x8]
				
				POP {R0-R12, LR}
                MOV      PC, LR

/* 
 * Configure the Generic Interrupt Controller (GIC)
*/
                .global  CONFIG_GIC
CONFIG_GIC:
                PUSH     {LR}
                MOV      R0, #29
                MOV      R1, #CPU0
                BL       CONFIG_INTERRUPT
                
                /* Enable the KEYs interrupts */
                MOV      R0, #73
                MOV      R1, #CPU0
                /* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
                BL       CONFIG_INTERRUPT

                /* configure the GIC CPU interface */
                LDR      R0, =0xFFFEC100        // base address of CPU interface
                /* Set Interrupt Priority Mask Register (ICCPMR) */
                LDR      R1, =0xFFFF            // enable interrupts of all priorities levels
                STR      R1, [R0, #0x04]
                /* Set the enable bit in the CPU Interface Control Register (ICCICR). This bit
                 * allows interrupts to be forwarded to the CPU(s) */
                MOV      R1, #1
                STR      R1, [R0]
    
                /* Set the enable bit in the Distributor Control Register (ICDDCR). This bit
                 * allows the distributor to forward interrupts to the CPU interface(s) */
                LDR      R0, =0xFFFED000
                STR      R1, [R0]    
    
                POP      {PC}
/* 
 * Configure registers in the GIC for an individual interrupt ID
 * We configure only the Interrupt Set Enable Registers (ICDISERn) and Interrupt 
 * Processor Target Registers (ICDIPTRn). The default (reset) values are used for 
 * other registers in the GIC
 * Arguments: R0 = interrupt ID, N
 *            R1 = CPU target
*/
CONFIG_INTERRUPT:
                PUSH     {R4-R5, LR}
    
                /* Configure Interrupt Set-Enable Registers (ICDISERn). 
                 * reg_offset = (integer_div(N / 32) * 4
                 * value = 1 << (N mod 32) */
                LSR      R4, R0, #3               // calculate reg_offset
                BIC      R4, R4, #3               // R4 = reg_offset
                LDR      R2, =0xFFFED100
                ADD      R4, R2, R4               // R4 = address of ICDISER
    
                AND      R2, R0, #0x1F            // N mod 32
                MOV      R5, #1                   // enable
                LSL      R2, R5, R2               // R2 = value

                /* now that we have the register address (R4) and value (R2), we need to set the
                 * correct bit in the GIC register */
                LDR      R3, [R4]                 // read current register value
                ORR      R3, R3, R2               // set the enable bit
                STR      R3, [R4]                 // store the new register value

                /* Configure Interrupt Processor Targets Register (ICDIPTRn)
                  * reg_offset = integer_div(N / 4) * 4
                  * index = N mod 4 */
                BIC      R4, R0, #3               // R4 = reg_offset
                LDR      R2, =0xFFFED800
                ADD      R4, R2, R4               // R4 = word address of ICDIPTR
                AND      R2, R0, #0x3             // N mod 4
                ADD      R4, R2, R4               // R4 = byte address in ICDIPTR

                /* now that we have the register address (R4) and value (R2), write to (only)
                 * the appropriate byte */
                STRB     R1, [R4]
    
                POP      {R4-R5, PC}
                .end   
