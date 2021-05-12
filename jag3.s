.data

.balign 4
string: .asciz "%s\n"

.balign 4
num: .asciz "%d\n"

.balign 4
float: .asciz "%lf\n"

.balign 4
floatScan: .asciz "%lf"

.balign 4
arg1: .word 1

.balign 4
integer: .word 1

.balign 4
newstring: .word 1

.balign 4
string1: .asciz "abcdefghijklmnopqrstuvwxyz"

.balign 4
dividemessage: .asciz "divide\n"

.balign 4
openParenthesismessage: .asciz "open parenthesis\n"

.balign 4
closedParenthesismessage: .asciz "closed parenthesis\n"

.balign 4
list1HeadPointer: .space 8

.balign 4
list2HeadPointer: .space 8

.balign 4
list2TailPointer: .space 8

.balign 4
tmpFloat: .space 20

.text

.global printf
.global main
.global atof
.global malloc
.global strlen
.global memcpy

// Node struct
// void* value (0-7 bytes)
// node* next (8-15 bytes)

// Num struct
// float value (0-19 bytes)

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

	// initializing offset
    mov r2, #0
	mov r4, #0

loop:
	// loading individual bytes from arg1
	ldrb r3, [r1, r2]
	
	// debugging to see which byte was read
	push {r0-r12, lr}
    ldr r0, =num
	mov r1, r3
	bl printf
	pop {r0-r12, lr}

 	// increment pointer to byte
    add r2, r2, #1

    // find size of num1
    add r4, r4, #1

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

	bne loop

ifIsSymbol:
    push {r0-r12, lr}
    ldr r6, =string1
    bl buildString
    pop {r0-r12, lr}
    mov r4, #0
    bx lr
//

// buildString is a function that creates and adds a new
// float to the queue
buildString:
    push {r0-r12, lr}

    // Copy the given number to a new point in memory
    add r1, r1, r2
    sub r1, r1, r4
    mov r0, r6
    mov r2, r4
	push {r0-r12, lr}
    bl memcpy
	pop {r0-r12, lr}

	// Null terminate the string
	add r2, r2, r2
	sub r2, r2, #1
	mov r1, #0
	strb r1, [r2]

	// convert to a float
	//r0 is already set
	ldr r1, =floatScan
	ldr r2, =tmpFloat
	push {r0-r12, lr}
	bl sscanf
	pop {r0-r12, lr}
	ldr r1, =tmpFloat
	vldr d0, [r1]


	// Create a new num in memory
	mov r0, #20
	bl malloc

	// Store the number into that memory
	vstr d0, [r0]

	// Push it onto the queue
	bl queuePush

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

// stackPush inserts the value at r0 into
// list1 at the start
stackPush:
	// Move r0 into r3 as r0 is about to be overwritten
	mov r3, r0

	// Get 16 bytes of space from heap
	mov r0, #16
	bl malloc

	// Get current head pointer
	ldr r6, =list1HeadPointer
	ldr r5, [r6]

	// Store data into new node
	str r3, [r0]

	// Set current head pointer to new node's next
	add r1, r0, #8
	str r5, [r1]

	// Set new pointer as new head
	str r0, [r6]

	// Return
	bx lr

// stackPop pops the top value in the stack
// and returns it via r0
stackPop:
	// Get head pointer
	ldr r1, =list1HeadPointer
	ldr r2, [r1]

	// Load in the value to return
    ldr r0, [r2]

	// Get pointer to head->next
	add r2, r1, #8
	ldr r2, [r2]

	// Set the head->next pointer to be the new head pointer
	str r2, [r1]

	// Return
	bx lr

// queuePush inserts the value at r0 into
// list2 at the end
queuePush:
	// Move r0 into r3 as r0 is about to be overwritten
	mov r3, r0

	// Get 16 bytes of space from heap
	mov r0, #16
	bl malloc

	// Get current tail pointer
	ldr r6, =list2TailPointer
	ldr r5, [r6]

	// If tail pointer is null, skip this next operation
	cmp r5, #0
	beq queuePush1

	// Store the new node as the next of the current tail pointer
	add r5, r5, #8
	str r0, [r5]

	// Else
	b queuePush2
queuePush1:
	// Set head to be the new node
	ldr r7, =list2HeadPointer
	str r0, [r7]

queuePush2:
	// Set tail to be the new node
	str r0, [r6]

	// Return
	bx lr

// queuePop pops the top value in the queue
// and returns it via r0
queuePop:
		// Get head pointer
    	ldr r1, =list2HeadPointer
    	ldr r2, [r1]

    	// Load in the value to return
        ldr r0, [r2]

    	// Get pointer to head->next
    	add r2, r1, #8
    	ldr r2, [r2]

    	// Set the head->next pointer to be the new head pointer
    	str r2, [r1]

    	// If the head is not null, return here
    	cmp r2, #0
    	bxne lr

    	// Set tail to the same null
    	ldr r1, =list2TailPointer
    	str r2, [r1]

    	// Return
    	bx lr

end:
//	ldr r0, =num
//	mov r1, r1
//	bl printf
//	pop {r0-r12, lr}  //the push/pop was for debugging purposes	

	mov r7, #1
	swi 0	
	
