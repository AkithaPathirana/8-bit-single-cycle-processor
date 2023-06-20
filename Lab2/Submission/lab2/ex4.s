@ ARM Assembly - exercise 4
@ Group Number :

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values
	mov r0, #3
	mov r1, #5
	mov r2, #7
	mov r3, #-8


	@ Write YOUR CODE HERE
	@ if (i>5) f = 70;
	@ else if (i>3) f=55;
	@ else f = 30;
	@ i  in r0
	@ Put f to r5
	@ Hint : Use MOV instruction
	@ MOV r5,#70 makes r5=70

	@ ---------------------

  MOV r6,#5;         @put 5 in r6
  CMP r0,r6;         
	BGT DO1;      @execute if i>5
	MOV r7,#3;    @put 3 in r7
	CMP r0,r7;
	BGT DO2;      @execute if i>3
	MOV r5,#30;   @put 30 in r5
	B Exit;

DO1:
  MOV r5,#70;
	B Exit;
DO2:
  MOV r5,#55;
	B Exit;

Exit:

	
	@ ---------------------


	@ load aguments and print
	ldr r0, =format
	mov r1, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "The Answer is %d (Expect 30 if correct)\n"
