BINARY = program.elf

OBJECTS += main.o
OBJECTS += startup.o
OBJECTS += systick.o
OBJECTS += stm32f103-md-vectors.o
LDSCRIPT = stm32f103c8.ld

##############################################################################

TOOL_PREFIX = arm-none-eabi-

AS = $(TOOL_PREFIX)as
CC = $(TOOL_PREFIX)gcc
CXX = $(TOOL_PREFIX)g++
CPP = $(TOOL_PREFIX)cpp
LD = $(TOOL_PREFIX)ld

# Enabling semihosting allows you to use printf() et al without a serial
# adapter, but requires a debugger to be attached at all times.
USE_SEMIHOSTING = 0

##############################################################################

CPUFLAGS  += -mcpu=cortex-m3 -mfpu=vfp

CPPFLAGS  += -Ivendor/CMSIS_5/CMSIS/Core/Include
CPPFLAGS  += -Ivendor/cmsis_device_f1/Include

CFLAGS    += $(CPUFLAGS) $(CPPFLAGS)
ASFLAGS   += $(CPUFLAGS) $(CPPFLAGS)

CFLAGS    += -Os
CFLAGS    += -Wall -Werror
CFLAGS    += -g3 -gz -fno-eliminate-unused-debug-types
CFLAGS    += -ffunction-sections -fdata-sections

LDFLAGS   += $(CPUFLAGS) -e Reset_Handler
LDFLAGS   += -Wl,-compress-debug-sections=zlib -Wl,-nmagic
LDFLAGS   += -Wl,-gc-sections

LDFLAGS   += --specs=nano.specs

GENERATED += $(LDSCRIPT).gen

ifeq ($(USE_SEMIHOSTING),1)
LDFLAGS += --specs=rdimon.specs
else
LDFLAGS += --specs=nosys.specs
endif

##############################################################################

default: $(BINARY)

$(BINARY): $(OBJECTS) $(LDSCRIPT).gen
	$(CC) $(LDFLAGS) -T $(LDSCRIPT).gen $(OBJECTS) -o $@

$(LDSCRIPT).gen: $(LDSCRIPT) Makefile
	$(CPP) -MD -MT $@ -P $(LDSCRIPT) -o $@

%.o: %.s
	$(AS) --MD $*.d $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -MMD -c $(CFLAGS) $< -o $@

%.o: %.cpp
	$(CXX) -MMD -c $(CFLAGS) $< -o $@

-include $(OBJECTS:.o=.d)
-include $(LDSCRIPT).d

clean:
	rm -f $(BINARY) $(OBJECTS) $(GENERATED) \
	    $(OBJECTS:.o=.d) $(LDSCRIPT).d

.PHONY: default clean

.SUFFIXES: # disable all built-in suffix rules
