@ ARM Assembly - lab 3.1
@
@ Roshan Ragel - roshanr@pdn.ac.lk
@ Hasindu Gamaarachchi - hasindu@ce.pdn.ac.lk

	.text 	@ instruction memory


@ Write YOUR CODE HERE

@ ---------------------
mypow:

 mov r2,#1         @setting up a register to calculate the sum
 cmp r1,#0
 beq Exit           @answer is 1

Loop1:
 cmp r1,#1
 bge label1
 b Exit

label1:
 mul r3,r2,r0       @multiply sum with value and temporarily hold the value in r3
 mov r2,r3          @ move the above value to r2
 sub r1,r1,#1       @substract the value of n
 b Loop1

Exit:
 mov r0,r2         @move the sum in r2 to r0
 mov pc,lr         @exit the loop



@ ---------------------

	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #8 	@the value x
	mov r5, #3 	@the value n


	@ calling the mypow function
	mov r0, r4 	@the arg1 load
	mov r1, r5 	@the arg2 load
	bl mypow
	mov r6,r0


	@ load aguments and print
	ldr r0, =format
	mov r1, r4
	mov r2, r5
	mov r3, r6
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "%d^%d is %d\n"
