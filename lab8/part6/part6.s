.define LED_ADDRESS 0x10 
.define SW_ADDRESS 0x30
.define COUNT 0x000001//00

	  mv r1, #0

MAIN: 
	  mvt r0, #LED_ADDRESS
      add r1, #1  
      st r1, [r0]

      mvt r2, #SW_ADDRESS
      ld r3, [r2]

      add r3, #0
	  bpl OUTER_START
	  b MAIN
	  
OUTER_START:
	  add r3, #2
OUTER_LOOP:
	  sub r3, #1
	  bne INNER_LOOP
	  b MAIN
INNER_LOOP:
	  mvt r4, #COUNT
	  b DELAY
DELAY:
 	  sub r4, #1 
	  bne DELAY
	  b OUTER_LOOP
