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

main:
    // Read user-input
    ldr r2, [sp, #8] 
    add r2, r2, #4
    ldr r1, =arg1
    ldr r1, [r2]

    //debugging purposes, checking to make sure it read arg[1] properly 
//  push {r0-r12, lr}
//  ldr r0, =string
//  bl printf  
//  pop {r0-r12, lr}  
    //initializing offset
    mov r2, #0
    mov r4, #0

loop:
    //loading individual bytes from arg1
    ldrb r3, [r1, r2]

    //debugging to see which byte was read
//  push {r0-r12, lr}
//  ldr r0, =num
//  mov r1, r3
//  bl printf
//  pop {r0-r12, lr}

    //increment pointer to byte
    add r2, r2, #1  

    cmp r3, #40
    beq buildString
    cmp r3, #41
    beq buildString
    cmp r3, #94
    beq buildString
    cmp r3, #47
    beq buildString
    cmp r3, #42
    beq buildString
    cmp r3, #45
    beq buildString
    cmp r3, #43
    beq buildString

    //find size of num1
    add r4, r4, #1
    bne loop

buildString:
    sub r5, r2, #1 //# of bytes in argument until last byte of num (--> first byte)
    sub r5, r5, r4 //r5 contains offset to first byte of num
    mov r6, #0  

buildStringLoop:
    ldrb r3, [r1, r5]

    // append byte to string
    ldr r6, =string1
    str r3, [r6, r5]

    //debugging purposes only
//  push {r0-r12, lr}
//  ldr r0, =string
//  ldr r1, =string1
//  bl printf   
//  pop {r0-r12, lr}    

    add r5, r5, #1
    add r6, r5, #1
    cmp r6, r2
//  moveq r6, #0
//  streq r6, [r6, r5]  
    beq stringToFloat
    bne buildStringLoop

stringToFloat:
    push {r0-r12, lr}
    ldr r0, =string1
    bl atof

//  mov r0, r0
//  ldr r0, =num
//  bl printf
//  pop {r0-r12, lr}

    b end

checkOperator:
    cmp r3, #40
    beq openParenthesis
    cmp r3, #41
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
//  ldr r0, =num
//  mov r1, r1
//  bl printf
//  pop {r0-r12, lr}  //the push/pop was for debugging purposes

    ldr r0, =string
    ldr r1, =string1
    bl printf

    mov r7, #1
    swi 0
