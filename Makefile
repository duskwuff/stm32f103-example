TOOL_PREFIX = arm-none-eabi-

AR = $(TOOL_PREFIX)ar
AS = $(TOOL_PREFIX)as
CC = $(TOOL_PREFIX)gcc
CXX = $(TOOL_PREFIX)g++
CPP = $(TOOL_PREFIX)cpp
LD = $(TOOL_PREFIX)ld

# Enabling semihosting allows you to use printf() et al without a serial
# adapter, but requires a debugger to be attached at all times.
USE_SEMIHOSTING = 0

##############################################################################

CPUFLAGS += -mcpu=cortex-m3 -mfix-cortex-m3-ldrd -mfpu=vfp
FLAGS += -ISTM32CubeF1/Drivers/CMSIS/Core/Include
FLAGS += -ISTM32CubeF1/Drivers/CMSIS/Device/ST/STM32F1xx/Include

FLAGS += $(CPUFLAGS) $(DEFINES)
FLAGS += -Wall -Werror
FLAGS += -Os
FLAGS += -g3 -gz -fno-eliminate-unused-debug-types
FLAGS += -ffunction-sections -fdata-sections

CFLAGS += $(FLAGS) -std=gnu99
CXXFLAGS = $(CFLAGS)

LDSCRIPT = ldscript.ld
LDFLAGS += $(CPUFLAGS)

VECTORTYPE = stm32f1

LDFLAGS += --specs=nano.specs

ifeq ($(USE_SEMIHOSTING),1)
LDFLAGS += --specs=rdimon.specs
else
LDFLAGS += --specs=nosys.specs
endif

##############################################################################

%.a: $(OBJECTS)
	$(AR) cru $@ $+

BINARY = program.elf

OBJECTS += main.o
OBJECTS += startup.o vectors.o

GENERATED = $(LDSCRIPT).gen vectors.s

##############################################################################

default: $(BINARY)

$(LDSCRIPT).gen: $(LDSCRIPT) Makefile
	$(CPP) -P $(LDSCRIPT) -o $(LDSCRIPT).gen

vectors.s: $(VECTORTYPE).vec mkvectors.pl
	perl mkvectors.pl $< > $@

$(BINARY): $(OBJECTS) $(LDSCRIPT).gen
	$(CXX) $(LDFLAGS) -T $(LDSCRIPT).gen $(OBJECTS) -o $@

clean:
	rm -f $(BINARY) $(OBJECTS) $(GENERATED)
