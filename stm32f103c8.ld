MEMORY
{
    FLASH (rx)          : ORIGIN = 0x08000000, LENGTH = 64K
    SRAM (rwx)          : ORIGIN = 0x20000000, LENGTH = 20K
}

#define VECTOR_SPACE    SRAM
#define CODE_SPACE      SRAM
#define RODATA_SPACE    SRAM
#define DATA_SPACE      SRAM
#define STACK_SPACE     SRAM

#include "ld-common.ld"
