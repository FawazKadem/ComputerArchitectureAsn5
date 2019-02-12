		AREA assignment5, CODE, READONLY
N		EQU 2
X		EQU 3
		ENTRY
		
		LDR sp, =opStack;				get the stack
		MOV r0, #N;
		MOV r3, #X;
		STR r0, [sp, #-4]!; 			storing n into the stack
		SUB sp, #4; 					allocating space for the return value on the stack
		BL	pwr;						a call on the function that will go recursively
	
		;								the program will come here after all the recursion is done
		LDR	r0, [sp], #4; 				get from the stack the value of answer in r0
		ADD	sp, #4; 					this is to remove the parameter from the stack
		LDR r1, =answer; 				load in r1 the address of answer so that we can store it in memory 
		STR	r0, [r1]; 					this stores answer in the address of r1 which is pointing to the variable answer
		MOV r3, #0;						clear r3
		MOV r4, #0;						clear r4
		MOV r1, #0;						clear r1
endless B endless;			`			loop at the end of the program to keep it from going out of bounds

		AREA assignment5, CODE, READONLY
			
pwr 	STMFD sp!, {r0,r1,r2,fp,lr}; 	put all the registers you want into the stack
		MOV fp, sp; 					set the fp for this call
		SUB sp, #4; 					allocate space for the return variable 
		
		LDR r0, [fp, #0x18]; 			get n from the stack
		CMP r0, #0x00; 					compare the value of n
		BEQ zero; 						jump to zero if n ==0
		
		AND r2, r0, #2_00000001; 		this does the n&1
		CMP r2, #2_00000001; 			so if n is even then jump to even  
		BNE even; 						go to even
		;								if the program stays it means n is odd
		SUB r1, r0, #1; 				for n-1
		STR r1,[sp,#-4]!; 				store n-1 on the stack
		SUB sp, #4; 					allocate space for return value
		BL pwr; 						do (x)*(power(x,n-1))
		
		LDR	r1, [sp], #4; 
		ADD sp, #4;						go over the return space
		MUL r2, r1, r3; 				x * power(x, n - 1)
		STR r3, [fp, #0x14]; 			store the value of x in the return space
		B endS; 						end the stack
	
		
endS	MOV sp, fp; 					to empty the stack		
		LDMFD	sp!, {r0,r1,r2,fp,pc}; 	return to the caller and return the registers
		
zero	MOV r0, #1; 					this is because we have to return 1
		STR r0, [fp, #0x18]; 			store return 1 in the stack
		B endS;							
	
even	MOV r0, r0, LSR #1; 			r0/2
		STR r0, [sp, #-4]!;				store it in the stack
		SUB sp, #4; 					allocate space for the return value
		BL pwr; 						go back to the pwr statement
		
		;								program comes here to do the y*y
		LDR r4, [sp], #4;
		ADD	sp, #4; 					go over the return space 
		MUL r2, r4, r4; 				do y*y
		STR r2, [fp, #0x14]; 			put that value in the return space
		B endS; 						to empty the stack
		
		AREA assignment5, CODE, READWRITE
answer 	DCD	0x00;
		SPACE 0xF4; 					declare some space for the stack
opStack DCD 0x00;						initial stack position
		END