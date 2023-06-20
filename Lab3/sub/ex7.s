@ ARM Assembly - exercise 7
@ Group Number : goup 03

	.text 	@ instruction memory


@ Write YOUR CODE HERE

@ ---------------------
@ Fib(int num )
@ if(num>2 )
@  Fib(num)=Fin(num-1)+Fib(num-2)
@else
@  Fib(num)=1

Fibonacci:
 sub sp,sp,#8             @reseving 2 places in the stack to save lr and r0
 str lr,[sp,#4]
 str r0,[sp,#0]
 cmp r0,#2
 bgt L1
 mov r0,#1                @hold the return value in r0
 b Exit

L1:
 ldr r0,[sp,#0]
 sub r0,r0,#1
 bl Fibonacci                 @Fib(num-1)
 sub sp,sp,#4
 str r0,[sp,#0]
 ldr r0,[sp,#4]
 sub r0,r0,#2
 bl Fibonacci                 @Fib(num-2)
 ldr r1,[sp,#0]
 add sp,sp,#4
 add r0,r0,r1
 b Exit

Exit:
 ldr lr,[sp,#4]
 add sp,sp,#8
 mov pc,lr                       @return







@ ---------------------

	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #8 	@the value n

	@ calling the Fibonacci function
	mov r0, r4 	@the arg1 load
	bl Fibonacci
	mov r5,r0


	@ load aguments and print
	ldr r0, =format
	mov r1, r4
	mov r2, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "F_%d is %d\n"
