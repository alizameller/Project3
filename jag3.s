.data

.balign 4
string: .asciz "%s\n"

.balign 4
stringNoLF: .asciz "%s "

.balign 4
num: .asciz "%d\n"

.balign 4
charNoLF: .asciz "%c "

.balign 4
float: .asciz "\n%g\n"

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
.global pow

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
	b finalizePostfix

ifIsSymbol:
	push {r0-r12, lr}
	bl buildString
	pop {r0-r12, lr}

	// If it's a null, head return now
	cmp r3, #0
	bxeq lr

	// call handlePushingSymbol to push the symbol into the stack
	push {r0-r12, lr}
	mov r7, r3
	bl handlePushingSymbol
	pop {r0-r12, lr}

	mov r4, #0
	bx lr

// Expected r7 to be the symbol
handlePushingSymbol:
	mov r0, r7

	// If the stack is empty, skip to pushing symbol
	push {r0-r12, lr}
	bl stackEmpty
	pop {r0-r12, lr}
	beq handlePushingSymbol1

	// If the character is a left parenthesis, skip to pushing symbol
	cmp r7, #40
	beq handlePushingSymbol1

	// If the character is a right parenthesis, skip to special handling
	cmp r7, #41
	beq handlePushingSymbol2

	// Get the top of the stack
	push {r1-r12, lr}
	bl stackPeek
	pop {r1-r12, lr}

	mov r1, r7

	// Compare it to the value we current have
	push {r12, lr}
	bl precedence
	pop {r12, lr}

	blt handlePushingSymbol1

	// Pop from the stack and push it to the queue
	push {r7, lr}
	bl stackPop
	bl queuePush
	pop {r7, lr}


handlePushingSymbol1:
	// push on the remaining character
	mov r0, r7
	push {r0-r12, lr}
	bl stackPush
	pop {r0-r12, lr}

	bx lr

// handlePushingSymbol2 is specifically for dealing with right parenthesis
handlePushingSymbol2:
	// Pop the top of the stack
	push {r1-r12, lr}
	bl stackPop
	pop {r1-r12, lr}

	// If it is not a left parenthesis, pop then push to queue
	cmp r0, #40
	push {r0-r12, lr}
	blne queuePush
	pop {r0-r12, lr}

	// If it is not a left parenthesis, repeat
	cmp r0, #40
	bne handlePushingSymbol2

	bx lr

// buildString is a function that creates and adds a new
// string to the queue (Kept as a string so it is possible to tell the difference
// between a symbol and a number)
buildString:
	// If the string length is 0, return immediately
	cmp r4, #1
	bxeq lr
	push {r0-r12, lr}

	// Copy the given number to a new point in memory
	// Make memory for the string
	mov r0, r4

	push {r1-r12, lr}
	bl malloc
	pop {r1-r12, lr}

	// Copy into new memory space
	add r1, r1, r2
	sub r1, r1, r4
	mov r2, r4

	push {r0-r12, lr}
	bl memcpy
	pop {r0-r12, lr}

	// Null terminate the string
	add r2, r2, r0
	sub r2, r2, #1
	mov r1, #0
	strb r1, [r2]

	// Push the string onto the queue
	push {r12, lr}
	bl queuePush
	pop {r12, lr}

	pop {r0-r12, lr}
	bx lr

finalizePostfix:
	// While the stack is not empty, pop from the stack and push to the queue.
	bl stackEmpty
	beq solveExpression

	bl stackPop
	bl queuePush

	b finalizePostfix

// Now, the stack is empty and the queue contains
// a postfix expression. Let's solve it.
solveExpression:
	bl queueEmpty
	beq finalPrint

	bl queuePop

	// If it's less than 100, we can resonably assume it's not a pointer
	cmp r0, #100
	blt solveExpression1

	// If we're here, it means this is a string with a float
	// so calculate the float and place it into the stack as a float

	// DEBUG: Print out the number
	push {r0-r12, lr}
	mov r1, r0
	ldr r0, =stringNoLF
	bl printf
	pop {r0-r12, lr}

	// convert to a float
	// r0 is already set
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

	// Push it onto the stack
	bl stackPush
	b solveExpression

solveExpression1:
	// If we're here, it means that this is an operator
	// so we must solve the operator.
	// Determine what operator it is then call the
	// respective function.

	// DEBUG: Print out the operator
	push {r0-r12, lr}
	mov r1, r0
	ldr r0, =charNoLF
	bl printf
	pop {r0-r12, lr}

	push {r0-r12, lr}
	cmp r0, #94
	bleq exponent
	pop {r0-r12, lr}
	
	push {r0-r12, lr}
	cmp r0, #47
	bleq divide
	pop {r0-r12, lr}
	
	push {r0-r12, lr}
	cmp r0, #42
	bleq multiply
	pop {r0-r12, lr}
	
	push {r0-r12, lr}
	cmp r0, #45
	bleq subtract
	pop {r0-r12, lr}
	
	push {r0-r12, lr}
	cmp r0, #43
	bleq add
	pop {r0-r12, lr}
	b solveExpression

// Adds the top 2 values on the stack
add:
	push {r12, lr}
	bl stackPop
	vldr d0, [r0]

	bl stackPop
	vldr d1, [r0]
	
	vadd.f64 d0, d0, d1

	vstr d0, [r0]
	bl stackPush
	pop {r12, lr}
	bx lr	

// Subtracts the top 2 values on the stack
subtract:
	push {r12, lr}
	bl stackPop
	vldr d0, [r0]

	bl stackPop
	vldr d1, [r0]
	
	vsub.f64 d0, d1, d0

	vstr d0, [r0]
	bl stackPush
	pop {r12, lr}
	bx lr	

// Multiplies the top 2 values on the stack
multiply:
	push {r12, lr}
	bl stackPop
	vldr d0, [r0]

	bl stackPop
	vldr d1, [r0]
	
	vmul.f64 d0, d0, d1

	vstr d0, [r0]
	bl stackPush
	pop {r12, lr}
	bx lr	

// Divides the top 2 values on the stack
divide:
	push {r12, lr}
	bl stackPop
	vldr d0, [r0]

	bl stackPop
	vldr d1, [r0]

	vdiv.f64 d0, d1, d0

	vstr d0, [r0]
	bl stackPush
	pop {r12, lr}
	bx lr	

// Does the 2nd to top value on the stack to the power
// of the top value on the stack.
exponent:
	// Use the c stdlib.h pow function
	push {r12, lr}

	bl stackPop
	vldr d0, [r0]

	bl stackPop
	vldr d1, [r0]

	// Save a point to this float struct for later use
	mov r8, r0

	// Move the doubles into registers to call the c pow function.
	vmov r0, r1, d1
	vmov r2, r3, d0

	push {r2-r12, lr}
	bl pow
	pop {r2-r12, lr}

	// Move it back into the float register
	vmov d0, r0, r1

	// Store it back into a float struct and push it onto the stack
	vstr d0, [r8]
	mov r0, r8
	bl stackPush
	pop {r12, lr}
	bx lr

// stackPush inserts the value at r0 into
// list1 at the start
stackPush:
	push {r12, lr}
	// Move r0 into r3 as r0 is about to be overwritten
	mov r3, r0

	// Get 16 bytes of space from heap
	mov r0, #16
	push {r1-r12, lr}
	bl malloc
	pop {r1-r12, lr}

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
	pop {r12, lr}
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
	add r2, r2, #8
	ldr r2, [r2]

	// Set the head->next pointer to be the new head pointer
	str r2, [r1]

	// Return
	bx lr

// stackEmpty checks if the top of the stack is empty
// and returns it via CPSR
stackEmpty:
	push {r0-r12, lr}
	ldr r1, =list1HeadPointer
	ldr r1, [r1]
	cmp r1, #0
	pop {r0-r12, lr}
	bx lr

// stackPeek peeks at the top value
// in the stack and returns it via r0
stackPeek:
	ldr r0, =list1HeadPointer
	ldr r0, [r0]
	ldr r0, [r0]
	bx lr

// queuePush inserts the value at r0 into
// list2 at the end
queuePush:
	push {r0, lr}
	// Move r0 into r3 as r0 is about to be overwritten
	mov r3, r0

	// Get 16 bytes of space from heap
	mov r0, #16
	push {r1-r12, lr}
	bl malloc
	pop {r1-r12, lr}

	// Store the value into the new node
	str r3, [r0]

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
	pop {r0, lr}
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
	add r2, r2, #8
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

// queueEmpty checks if the top of the queue is empty
// and returns it via CPSR
queueEmpty:
	push {r0-r12, lr}
	ldr r1, =list2HeadPointer
	ldr r1, [r1]
	cmp r1, #0
	pop {r0-r12, lr}
	bx lr

// precedence returns a precedence comparison
// between r0 and r1 and returns it in PRSR
precedence:
	push {r0-r12, lr}
	bl precedenceNum
	mov r3, r0
	mov r0, r1
	bl precedenceNum
	mov r4, r0
	cmp r3, r4
	pop {r0-r12, lr}
	bx lr

// precedenceNum returns a numerical representation
// for the precedence in r0 in r0.
//
// () returns 0
// +- returns 1
// */ returns 2
// ^ returns 3
precedenceNum:
	cmp r0, #43 // +
	moveq r0, #1
	bxeq lr

	cmp r0, #45 // -
	moveq r0, #1
	bxeq lr

	cmp r0, #42 // *
	moveq r0, #2
	bxeq lr

	cmp r0, #47 // /
	moveq r0, #2
	bxeq lr

	cmp r0, #94 // ^
	moveq r0, #3
	bxeq lr

	cmp r0, #40 // (
	moveq r0, #0
	bxeq lr

	cmp r0, #41 // )
	moveq r0, #0
	bxeq lr

	mov r0, #0
	bx lr

finalPrint:
	// Get the value at the top of the stack
	bl stackPop
	vldr d0, [r0]

	// Move it into r2, r3 for printing with printf
	vmov r2, r3, d0
	ldr r0, =float

	// Print with printf
	push {r0-r12, lr}
	bl printf
	pop {r0-r12, lr}

	// Quit
	b end

end:

	mov r0, #0
	mov r7, #1
	swi 0	
