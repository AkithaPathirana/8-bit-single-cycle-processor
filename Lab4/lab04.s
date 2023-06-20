@ ARM Assembly Lab4
@	Reverses a specified number of input strings
@	Call it from main
	.text	@ instruction memory

	.global main
main:

  @ stack handling
  @ push (store) lr to the stack
  sub	sp, sp, #4
  str	lr, [sp, #0]

	@printf for string
  ldr r0, =formati
  bl printf


  @allocate stack for input
	sub	sp, sp, #4

  @scanf for number of strings
	ldr	r0, =formatn
	mov	r1, sp
	bl	scanf	@scanf("%d",sp)

  @copy the input for number of strings from the stack
  ldr r4,[sp]

  @release stack
  add sp,sp,#4

  @check the validity of the user input
  cmp r4,#0
  bge else

  @user input is wrong.
  ldr r0, =formatw
  bl printf
  b exit

else:

  mov r5,#1 @to keep count of the string number
Loop1:
  cmp r5,r4
  bgt exit

  @allocate space for 200 chars.
  sub sp,sp,#200

  @ask for the input
  ldr r0, =formata
  mov r1,r5
  bl printf

	@scanf for string
	ldr	r0, =formats
	mov	r1, sp
	bl	scanf	@scanf("%s",sp)

	@function call
	mov	r0, sp
	bl	reverseString

	@print answer
	mov	r1, sp
	ldr	r0, =formats
	bl	printf

  @increment the count of the number of strings and release the stack
  add r5,r5,#1
  add sp,sp,#200

  b Loop1

exit:
  ldr lr,[sp,#0]
  add sp,sp,#4
  mov pc,lr

  @ stack handling (pop lr from the stack) and return
  ldr	lr, [sp, #0]
  add	sp, sp, #4
  mov	pc, lr


	@ a function to reverse the string
reverseString:
	mov	r1, r0	@ duplicate the address stored in r0
  mov r2,#0   @final index of the string

Loop2:
	ldrb	r3, [r1, #0]
	cmp	r3, #0
	beq	endLoop2

	add	r2, r2, #1	@ count length
	add	r1, r1, #1	@ move to the next element in the char array
	b	Loop2

endLoop2:
	@figure out the mid index of the string
  mov r3,#1
  and r1,r2,r3
  cmp r1,#0
  bne odd
  mov r3,r2, lsr #1  @mid index is in r3
  b go
odd:
  mov r3,r3, lsr #1
  add r3,r3,#1        @mid index is in r3
  b go

go:
  @save the string address, the length and the value of r10 in the stack
  sub sp,sp,#12
  str  r0,[sp,#8]   @string address
  str  r2,[sp,#4]   @length of the string
  str  r10,[sp,#0]  @value of r10

  add r1,r0,r2   @address at the end of the string

@reverse the string and store it
Loop3:
  cmp r3,#0
  ble endLoop3
  ldrb r2,[r0,#0]
  ldrb r10,[r1,#0]
  mov r12,r2
  mov r2,r10
  mov r10,r12
  strb r2,[r0,#0]
  strb r10,[r1,#0]
  add r0,r0,#1
  sub r1,r1,#1
  sub r3,r3,#1
  b Loop3

endLoop3:
  str r10,[sp,#0]
  str r2,[sp,#4]
  str r0,[sp,#8]
  add sp,sp,#12
  mov pc,lr

	.data	@ data memory
formati: .asciz "Enter the number of strings : "
formatw: .asciz "Invalid Number"
formata: .asciz "Enter input string %d:"
formatn: .asciz "%d"
formats: .asciz "%s"
