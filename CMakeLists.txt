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

project(program.elf LANGUAGES C CXX ASM)

set(CPUFLAGS -mcpu=cortex-m3 -mfloat-abi=soft)
set(LINKER_SCRIPT linker-stm32f103c8.ld)

add_executable(${PROJECT_NAME}
    main.c
    startup.c
    systick.c

    vectors-stm32f103-md.s
)

target_include_directories(${PROJECT_NAME} PUBLIC
    .
    vendor/CMSIS_6/CMSIS/Core/Include
    vendor/cmsis_device_f1/Include
)

target_link_directories(${PROJECT_NAME} PUBLIC
    .
)

set_property(TARGET ${PROJECT_NAME} PROPERTY C_STANDARD 17)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)
set_property(TARGET ${PROJECT_NAME} PROPERTY LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${LINKER_SCRIPT})

target_compile_options(${PROJECT_NAME} PUBLIC
    ${CPUFLAGS}

    # Automatically include project.h in all compilation units
    -include ${CMAKE_CURRENT_SOURCE_DIR}/project.h

    # Optimize for debuggability
    -Og

    # Enable all compile warnings, treat warnings as errors
    -Wall -Werror

    # Include debugging information in the .elf
    -g3 -gz
    -ffunction-sections -fdata-sections
)

target_link_options(${PROJECT_NAME} PUBLIC
    ${CPUFLAGS}

    --specs=nano.specs
    --specs=nosys.specs

    -e Reset_Handler
    LINKER:-T,${LINKER_SCRIPT}
    LINKER:--nmagic
    LINKER:--compress-debug-sections=zlib
    LINKER:-Map ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map

    # This disables an unnecessary warning: https://github.com/raspberrypi/pico-sdk/issues/1029
    LINKER:--no-warn-rwx-segments
)
