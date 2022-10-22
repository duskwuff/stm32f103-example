cmake_minimum_required(VERSION 3.21.0)

# This makes cmake generate compile_commands.json, which can be used by other tools like clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# Configure CMake to use the ARM GNU toolchain
set(CMAKE_SYSTEM_NAME generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

project(program LANGUAGES C CXX ASM)

add_executable(program.elf
    main.c
    systick.c

    startup.s
    vectors-stm32f103-md.s
)

target_include_directories(program.elf PUBLIC
    vendor/CMSIS_5/CMSIS/Core/Include
    vendor/cmsis_device_f1/Include
)

target_link_directories(program.elf PUBLIC
    .
)

set(CPUFLAGS -mcpu=cortex-m3 -mfloat-abi=soft)

set_property(TARGET program.elf PROPERTY C_STANDARD 17)
set_property(TARGET program.elf PROPERTY CXX_STANDARD 17)

target_compile_options(program.elf PUBLIC
    ${CPUFLAGS}

    # Optimize for debuggability
    -Og

    # Enable all compile warnings, treat warnings as errors
    -Wall -Werror

    # Include debugging information in the .elf
    -g3 -gz
    -ffunction-sections -fdata-sections
)

target_link_options(program.elf PUBLIC
    ${CPUFLAGS}

    --specs=nano.specs
    --specs=rdimon.specs

    -e Reset_Handler
    LINKER:-T,linker-stm32f103c8.ld
    LINKER:--nmagic
    LINKER:--compress-debug-sections=zlib
)
