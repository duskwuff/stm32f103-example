MEMORY
{
    FLASH (rx)          : ORIGIN = 0x08000000, LENGTH = 64K
    SRAM (rwx)          : ORIGIN = 0x20000000, LENGTH = 20K
}

/*
 * This size is advisory. The Cortex-M3 doesn't have an enforceable stack
 * limit; if the stack grows beyond this size, it may collide with the heap or
 * the data segment.
 */
__STACK_SIZE = 4096;

/*
 * This size is advisory as well. The C runtime will allow heap allocations to
 * use all available memory from the end of the data segment up to the stack
 * limit.
 */
__HEAP_SIZE = 4096;

REGION_ALIAS("VECTOR_SPACE",    FLASH)
REGION_ALIAS("CODE_SPACE",      FLASH)
REGION_ALIAS("RODATA_SPACE",    FLASH)
REGION_ALIAS("DATA_SPACE",      SRAM)
REGION_ALIAS("STACK_SPACE",     SRAM)
REGION_ALIAS("HEAP_SPACE",      SRAM)

INCLUDE "linker-arm.ld"
