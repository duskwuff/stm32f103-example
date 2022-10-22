# stm32f103-example

A tiny example project for the STM32F103.


## Requirements

### Software

* The [GNU ARM Embedded Toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)
* [CMake](https://cmake.org/)
* [OpenOCD](http://openocd.org/)

If you are on macOS, you can install all three with `brew install cmake openocd gcc-arm-embedded`.


### Hardware

* A STM32F103C8 "Blue Pill" or compatible board
* A ST-Link debug adapter (or a compatible clone)


## Building and debugging

Make sure you have checked out the submodules under `vendor/`. You can do this by running `git submodule update --init`.

To initialize the CMake project, run:

```
cmake .
```

This generates a `Makefile` which can be used to build the project. You can test this by running `make` now.

Set both BOOT jumpers on the microcontroller to 0, attach your debugger to the computer and the target, then start OpenOCD:

```
openocd -f stlink-f1.cfg
```

Leave this running in one terminal, then launch:

```
arm-none-eabi-gdb program.elf
```

in another terminal. If you see a warning about auto-loading, follow the instructions to enable autoloading in this directory, or run `source .gdbinit` to load the GDB configuration for this project.

You can now use `make` and `run` in that terminal to run the program.


## Booting from RAM

You will need the BOOT jumpers both set to 0 to run this program in the default boot-from-FLASH configuration. To run the program from SRAM, you can modify the memory regions in `linker-stm32f103c8.ld` as follows:

```
REGION_ALIAS("VECTOR_SPACE",    SRAM)
REGION_ALIAS("CODE_SPACE",      SRAM)
REGION_ALIAS("RODATA_SPACE",    SRAM)
REGION_ALIAS("DATA_SPACE",      SRAM)
REGION_ALIAS("STACK_SPACE",     SRAM)
```

and set both BOOT jumpers to 1.


## Hardware references

* [STM32F103C8 datasheet](https://www.st.com/resource/en/datasheet/stm32f103c8.pdf)
* [RM0008: STM32F1 reference manual](https://www.st.com/resource/en/reference_manual/cd00171190.pdf)
* [PM0056: Cortex-M3 programming manual](https://www.st.com/resource/en/programming_manual/cd00228163.pdf)
* [PM0075: STM32F1 flash programming manual](https://www.st.com/resource/en/programming_manual/cd00283419.pdf)


## Licensing

This is free and unencumbered software released into the public domain. Refer to `LICENSE.md` for details.
