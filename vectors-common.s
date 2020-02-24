.syntax unified
.thumb

.section .text.Default_Handler
.type Default_Handler, %function
Default_Handler:
    b .
.size Default_Handler, .-Default_Handler

.macro VECTOR id, name
.org 0x40 + 4 * \id
.word \name\()_Handler
.weak \name\()_Handler
.thumb_set \name\()_Handler, Default_Handler
.endm

.macro BOOTRAM loc
.org \loc
__isr_vector_BootRAM:
    ldr pc, [pc, -\loc]
.endm

.section .isr_vector, "a", %progbits
.align
.global __isr_vector
.type __isr_vector, %object

__isr_vector:
.word __stack

# Standard Cortex-M vectors
VECTOR -15, Reset
VECTOR -14, NMI
VECTOR -13, HardFault
VECTOR -12, MemManage
VECTOR -11, BusFault
VECTOR -10, UsageFault
VECTOR -5,  SVC
VECTOR -4,  DebugMon
VECTOR -2,  PendSV
VECTOR -1,  SysTick
