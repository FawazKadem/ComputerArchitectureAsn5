;program to computer X^N using a stack and store final value in "result"
;36 assembly instructions total
;Fawaz Mohammad 250913376
		AREA power, CODE, READONLY

X		EQU 2						;defines X value in X^N. i.e. the base
N		EQU 9						;defines N value in X^N. i.e. the exponent
SINGLE	EQU 4						;defines SINGLE, which represents the space needed to store a single element in the stack
NEXT	EQU 0x1C					;defines NEXT, which represents the amount of bytes between start of current frame and the stored result in the next frame
	
	
		ENTRY						;beginning of program
									;main program prepares X and N values and passes them to function. Then loads value from stack and stores it into result
MAIN	ADR sp, stack				;puts starting positioning of stack into sp to define the stack
		
		MOV r1, #X					;prepares exponent parameter
		MOV r2, #N					;prepares base
		
		STMFD sp!, {r0,r1,r2}		;pushes X and N onto the stack and makes room for r0 which will be a working register
		SUB sp,#SINGLE				;make room in stack to keep track of r0 value, so we can restore it in the end so function doesnt modify any registers

		BL	POWER					;call power function to compute X^N

		LDR r0,[sp,#SINGLE]			;loads result from the stack into a register so it can be stored in "result"
		STR r0,result				;stores X^N into result
		
		
ENDLOOP	B ENDLOOP					;end of prog


;----------------------------------------------------------------------------------------------------------------

		AREA power, CODE, READONLY	
									;POWER function computes X^N
POWER	STMFD sp!,{r0,r1,r2,fp,lr}	;stacks 3 general registers as well as fp and lr onto stack.
		
		STR r0,[sp,#-SINGLE]!		;reserve space for initial r0 value, so we can restore it before returning each call. to meet requirement that function cannot modify any registers
		MOV fp,sp					;set frame pointer for this call
		
		
		LDR r2,[fp,#0x0C]			;Loads exponent value from stack into r2, so we can use it to compute X^N
		
		CMP r2, #0;					;if (n==0)	
ZERO	MOVEQ r2,#1 				;store 1 in register we it can be returned to stack
		STREQ r2,[fp,#NEXT]			;return 1
		BEQ END_FR;					;end this call
		
		LDRNE r1,[fp,#0x08]			;load base value from stack
		
		TST r2, #0x01;				;if (n & 1), aka if n is odd
		BNE ODD						;compute X^N when N is odd


									;EVEN computes (X^(N/2))^2 if N is even
EVEN	MOVEQ r2, r2, ASR #1		;else, aka if n is even, divide n by 2 then return (X^N/2)^2

		BL POWER					;restart call to find what values of X^N/2 is, until we get a non-variable answer

		;
		
		LDR r0,[fp,#SINGLE]			;loads current result (y value)
		MOV r2, r0					;duplicates current result
		MUL r0, r2, r0				;y*y
		STR r0,[fp,#NEXT]			;stores y*y in the stack and the next calls result value.
		LDR r0,[fp]					;restores r0 register to value before the call so function doesn't modify it.

		B END_FR					;collapse current frame and go to next call




									;ODD computes (X^(N-1))*X if N is odd
ODD		SUB r2,r2,#1				;if N is odd, we decrement it by one

		BL POWER					;compute X^N-1
		
		LDR r0,[fp,#SINGLE]			;loads current result value, aka X^N-1
		MUL r0, r1, r0;				;multiples X^N-1 by X
		STR r0,[fp,#NEXT]			;stores X^N-1 * X into stack
		LDR r0,[fp]					;restores r0 register to value before call
		
		B END_FR					;collapse current frame and go to next call


		
									;END_FR collapses current frame and moves on to the next call
END_FR	ADD sp,fp,#0x08				;pops current result and restore value of r0 so they dont overwrite other things
		LDMFD sp!,{r1,r2,fp,pc}		;pops 4 stack elements to get the base value, exponent value, frame pointer, and where to go next
		
		
;----------------------------------------------------------------------------------------------------------------

		AREA power, DATA, READWRITE
		
result	DCD 0x00					;final answer. result = X^N.
		SPACE 0xC4					;Allocate space for contents of stack
stack	DCD 0x00					;Starting position of stack.
	
		END