.data

.balign 4
string: .asciz "%s\n"

.balign 4
num: .asciz "%d\n"

.balign 4
float: .asciz "%lf\n"

.balign 4
arg1: .word 1

.balign 4
integer: .word 1

.balign 4
newstring: .word 1

.balign 4
string1: .asciz "%s\n"

.balign 4
dividemessage: .asciz "divide\n"

.balign 4
openParenthesismessage: .asciz "open parenthesis\n"

.balign 4
closedParenthesismessage: .asciz "closed parenthesis\n"

.text

.global printf
.global main
.global atof
.global malloc
.global strlen
.global memcpy

main:
// Read user-input
	ldr r2, [sp, #8]
	add r2, r2, #4
	ldr r1, =arg1
	ldr r1, [r2]

	//debugging purposes, checking to make sure it read arg[1] properly	
//	push {r0-r12, lr}
//	ldr r0, =string
//	bl printf  
//	pop {r0-r12, lr}	

	//initializing offset
    mov r2, #0
	mov r4, #0

loop:
	//loading individual bytes from arg1
	ldrb r3, [r1, r2]
	
	//debugging to see which byte was read
	push {r0-r12, lr}
    ldr r0, =num
	mov r1, r3
	bl printf
	pop {r0-r12, lr}

 	//increment pointer to byte
    add r2, r2, #1  

	cmp r3, #41
    bleq ifIsSymbol
    cmp r3, #40
    bleq ifIsSymbol
    cmp r3, #94
    bleq ifIsSymbol
    cmp r3, #47
    bleq ifIsSymbol
    cmp r3, #42
    bleq ifIsSymbol
    cmp r3, #45
    bleq ifIsSymbol
    cmp r3, #43
    bleq ifIsSymbol
	cmp r3, #0
	bleq ifIsSymbol
	cmp r3, #0
	beq finalizePostfix

	//find size of num1
	add r4, r4, #1
	bne loop

ifIsSymbol:
    push {r0-r12, lr}
    ldr r6, =string1
    bl buildString
    pop {r0-r12, lr}
    mov r4, #0
    bx lr

buildString:
    push {r0-r12, lr}
    sub r1, r2, r4
    sub r1, r1, #1
    mov r0, r6
    mov r2, r4
    bl memcpy
    push {r0-r12, lr}
        ldr r0, =openParenthesismessage
        bl printf
        pop {r0-r12, lr}
    push {r0-r12, lr}
    ldr r0, =string
    ldr r1, =string1
    bl printf
    pop {r0-r12, lr}
	pop {r0-r12, lr}

	bx lr

queue:
	//push to queue
	push {r0-r12, lr}	
	ldr r0, =string
	ldr r1, =string1
	bl printf
	pop {r0-r12, lr}	

//	push {r0-r12, lr}
//  ldr r0, =num
//  mov r1, r3
//  bl printf
//  pop {r0-r12, lr}

	cmp r3, #0
	bne loop
	beq end

finalizePostfix:


checkOperator:
	cmp r3, #41
    beq openParenthesis
    cmp r3, #40
    beq closedParenthesis
    cmp r3, #94
    beq exponent
    cmp r3, #47
    beq divide
    cmp r3, #42
    beq multiply
    cmp r3, #45
    beq subtract
    cmp r3, #43
    beq add

add:
	//using add instruction adds the values in the registers
	mov r1, #3
    mov r2, #4
    add r1, r2, r1
    ldr r0, =num
    bl printf

	b end	

subtract:
	//using sub instructions subtracts values in the registers
	mov r1, #3
    mov r2, #4
    sub r1, r2, r1
    ldr r0, =num
    bl printf

	b end	

multiply:
	//using mul instruction multiplies the values in the registers
	mov r1, #3
    mov r2, #4
    mul r1, r2, r1
    ldr r0, =num
    bl printf

	b end

divide:
	ldr r0, =dividemessage
    ldr r1, =string
    bl printf
	b end

exponent:
    //loop mul instruction
    push {r0-r12, lr}
 	mov r2, #3 //base
    mov r3, #1 //exponent
	
	cmp r3, #0
	moveq r1, #1
	cmp r3, #1
	moveq r1, r2
	cmp r3, #2
	mulge r1, r2, r2
	bgt mulLoop 

	b end 

mulLoop:
	mul r1, r2, r1
	add r0, r0, #1
	cmp r0, r3
	bne mulLoop
	beq end

openParenthesis:
	ldr r0, =openParenthesismessage
    ldr r1, =string
    bl printf
	b end

closedParenthesis:
	ldr r0, =closedParenthesismessage
    ldr r1, =string
    bl printf
	b end

end:
//	ldr r0, =num
//	mov r1, r1
//	bl printf
//	pop {r0-r12, lr}  //the push/pop was for debugging purposes	

	mov r7, #1
	swi 0	
	
