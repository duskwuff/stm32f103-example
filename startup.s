.syntax unified
.cpu cortex-m3
.thumb

.global Default_Handler
.global Reset_Handler

.section .text.Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
    ldr     r1, =_sidata
    ldr     r2, =_sdata
    ldr     r3, =_edata
.L_init_data:
    cmp     r2, r3
    ittt    lt
    ldrlt   r0, [r1], #4
    strlt   r0, [r2], #4
    blt     .L_init_data

    bl      SystemInit

    b       _start
.size Reset_Handler, .-Reset_Handler
