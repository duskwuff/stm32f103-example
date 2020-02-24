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

CPUFLAGS += -mcpu=cortex-m3 -mfpu=vfp

CPPFLAGS += -ISTM32CubeF1/Drivers/CMSIS/Core/Include
CPPFLAGS += -ISTM32CubeF1/Drivers/CMSIS/Device/ST/STM32F1xx/Include

CFLAGS = $(CPUFLAGS) $(CPPFLAGS)
ASFLAGS = $(CPUFLAGS) $(CPPFLAGS)

CFLAGS += -Os
CFLAGS += -Wall -Werror
CFLAGS += -g3 -gz -fno-eliminate-unused-debug-types
CFLAGS += -ffunction-sections -fdata-sections

LDSCRIPT = ldscript.ld
LDFLAGS += $(CPUFLAGS)
LDFLAGS += -Wl,-compress-debug-sections=zlib -Wl,-nmagic
LDFLAGS += -Wl,-gc-sections

LDFLAGS += --specs=nano.specs

ifeq ($(USE_SEMIHOSTING),1)
LDFLAGS += --specs=rdimon.specs
else
LDFLAGS += --specs=nosys.specs
endif

##############################################################################

BINARY = program.elf

OBJECTS += main.o
OBJECTS += startup.o
OBJECTS += vectors-stm32f1.o

GENERATED = $(LDSCRIPT).gen

##############################################################################

default: $(BINARY)

$(BINARY): $(OBJECTS) $(LDSCRIPT).gen
	$(CC) $(LDFLAGS) -T $(LDSCRIPT).gen $(OBJECTS) -o $@

$(LDSCRIPT).gen: $(LDSCRIPT) Makefile
	$(CPP) -P $(LDSCRIPT) -o $(LDSCRIPT).gen

%.o: %.s
	$(AS) --MD $*.d $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -MMD -c $(CFLAGS) $< -o $@

%.o: %.cpp
	$(CXX) -MMD -c $(CFLAGS) $< -o $@

-include $(OBJECTS:.o=.d)

clean:
	rm -f $(BINARY) $(OBJECTS) $(GENERATED) $(OBJECTS:.o=.d)

.PHONY: default clean

.SUFFIXES: # disable all built-in suffix rules
