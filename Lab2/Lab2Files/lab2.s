@ ARM Assembly - lab 2
@ Group Number :

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values

	@ Write YOUR CODE HERE

	@	Sum = 0;
	@	for (i=0;i<10;i++){
	@			for(j=5;j<15;j++){
	@				if(i+j<10) sum+=i*2
	@				else sum+=(i&j);
	@			}
	@	}
	@ Put final sum to r5


	@ ---------------------
	MOV r1,#0;        @Sum=0 is stored in r1
	MOV r2,#0;        @i=0 is stored in r2
Loop1:
	CMP r2,#10;
	BGE Out1;
	MOV r3,#5;        @j=5 is stored in r3
	B Loop2:
	  CMP r3,#15;
		BGE Out2;
		ADD r4,r3,r2;          @i+j
		CMP r4,#10;
		BGE Out3;
		AND r5,r2,r3;          @i&j
		ADD r1,r1,r5;
		B Exit3;
	Out3:
	  ADD r1,r1,#2,LSL #1; @sum+=i*2
		Exit1;
	Exit3:
	  ADD r3,r3,#1;
	  B Loop2;
	Out2:
	 	ADD r2,r2,#1;
		B Loop1;
	Out1:
	 	MOV r5,r1;
		Exit;
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
format: .asciz "The Answer is %d (Expect 300 if correct)\n"
