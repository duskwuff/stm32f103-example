MEMORY
{
    FLASH (rx)          : ORIGIN = 0x08000000, LENGTH = 64K
    SRAM (rwx)          : ORIGIN = 0x20000000, LENGTH = 20K
}

/*
 * These defines control what memory spaces should be used for each section.
 *
 * To boot from SRAM on STM32F1, set all memory spaces to SRAM.
 */
#define VECTOR_SPACE    FLASH
#define CODE_SPACE      FLASH
#define RODATA_SPACE    FLASH
#define DATA_SPACE      SRAM
#define STACK_SPACE     SRAM

/* Special symbols and aliases */
_sidata = LOADADDR(.data);  /* used by startup */
__bss_start__ = _sbss;      /* required by crt0 */
__bss_end__ = _ebss;        /* required by crt0 */
__stack = ORIGIN(STACK_SPACE) + LENGTH(STACK_SPACE);

/* Define output sections */
SECTIONS
{
    /* Vector table -- must be at the top of memory */
    .isr_vector : {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } >VECTOR_SPACE

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
    } >RODATA_SPACE

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
    } >DATA_SPACE AT>RODATA_SPACE

    . = ALIGN(4);
    .bss : {
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } >DATA_SPACE

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
