@ ARM Assembly - exercise 6
@ Group Number : group3

	.text 	@ instruction memory


@ Write YOUR CODE HERE

@ ---------------------
fact:
  mov r3,#1     @factorial is assigned here
loop1:
 	cmp r0,#1     @ if value is less than 1 then leave the factorial value is found
	bge else
  mov r0,r3
	mov pc,lr

else:
  mul r3,r3,r0    @multiply the current value with the value in r3
  sub r0,#1       @reduce the value in r0 by 1
  b loop1

@ ---------------------

.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	mov r4, #8 	@the value n

	@ calling the fact function
	mov r0, r4 	@the arg1 load
	bl fact
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
format: .asciz "Factorial of %d is %d\n"
