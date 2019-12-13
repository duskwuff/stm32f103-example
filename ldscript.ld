MEMORY
{
    FLASH (rx)          : ORIGIN = 0x08000000, LENGTH = 64K
    SRAM (rwx)          : ORIGIN = 0x20000000, LENGTH = 20K
}

#define VEC_SPACE   FLASH 
#define CODE_SPACE  FLASH
#define LOAD_SPACE  FLASH
#define WORK_SPACE  SRAM
#define STACK_SPACE SRAM

__stack = ORIGIN(STACK_SPACE) + LENGTH(STACK_SPACE);
_Min_Heap_Size = 0;         /* required amount of heap  */
_Min_Stack_Size = 0x400;    /* required amount of stack */

/* Special symbols and aliases */
_sidata = LOADADDR(.data); /* used by startup */
__bss_start__ = _sbss; /* required by crt0 */
__bss_end__ = _ebss;   /* required by crt0 */

/* Define output sections */
SECTIONS
{
    /* Vector table -- must be at the top of memory */
    .isr_vector : {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } >CODE_SPACE

    . = ALIGN(4);

    .text : {
        *(.text)
        *(.text*)
        *(.glue_7)
        *(.glue_7t)
        *(.eh_frame)
        KEEP (*(.init))
        KEEP (*(.fini))
        . = ALIGN(4);
        _etext = .;
    } >CODE_SPACE

    .rodata : {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } >CODE_SPACE

    .ARM.extab : {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } >CODE_SPACE

    .ARM : {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } >CODE_SPACE

    .preinit_array : {
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array*))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    } >CODE_SPACE

    .init_array : {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array*))
        PROVIDE_HIDDEN (__init_array_end = .);
    } >CODE_SPACE

    .fini_array : {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(SORT(.fini_array.*)))
        KEEP (*(.fini_array*))
        PROVIDE_HIDDEN (__fini_array_end = .);
    } >CODE_SPACE

    . = ALIGN(4);
    .data : {
        _sdata = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } >WORK_SPACE AT>LOAD_SPACE

    . = ALIGN(4);
    .bss : {
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } >WORK_SPACE

    /* User_heap_stack section, used to check that there is enough RAM left */
    ._user_heap_stack : {
        . = ALIGN(8);
        PROVIDE ( end = . );
        PROVIDE ( _end = . );
        PROVIDE ( __end__ = . );
        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;
        . = ALIGN(8);
    } >WORK_SPACE

    /* Remove information from the standard libraries */
    /DISCARD/ : {
        libc.a ( * )
        libm.a ( * )
        libgcc.a ( * )
    }

    .ARM.attributes 0 : {
        *(.ARM.attributes)
    }
}
