@ ARM Assembly - lab 3.2
@ Group Number : group 3

	.text 	@ instruction memory


@ Write YOUR CODE HERE

@ ---------------------
@gcd(a,b)
gcd:
 sub sp,sp,#4
 str lr,[sp,#0]
 cmp r1,#0
 bnq L1
 b Exit

L1:
 udiv r2,r0,r1   @getting a mod b
 mul  r3,r2,r1   @getting a mod b
 sub  r2,r0,r3   @getting a mod b
 mov  r0,r1      @saving b in a
 mov  r1,r2      @saving a%b in b
 bl gcd
 b  Exit

Exit:
 mov lr,[sp,#0]
 add sp,sp,#4
 mov pc,lr     @qutting from the function



@ ---------------------

	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #64 	@the value a
	mov r5, #24 	@the value b


	@ calling the mypow function
	mov r0, r4 	@the arg1 load
	mov r1, r5 	@the arg2 load
	bl gcd
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
format: .asciz "gcd(%d,%d) = %d\n"
