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

Once you've done so, ensure your toolchain is working by running `make`. This will initialize CMake in the `build` directory and build the program. Some warnings from the toolchain about unimplemented functions like `_write` are normal. If this is successful, the last line of output should be:

```
[100%] Built target program.elf
```

Now you're ready to run your program. Set both BOOT jumpers on the microcontroller to 0, attach your debugger to the computer and the target, then start OpenOCD:

```shell
openocd -f stlink-f1.cfg
```

Leave this running in one terminal, then launch:

```shell
arm-none-eabi-gdb build/program.elf
```

in another terminal. If you see a warning about auto-loading, follow the instructions to enable autoloading in this directory, or run `source .gdbinit` to load the GDB configuration for this project.

You can now use `make` and `run` in that terminal to (re)build and run the program.


## Booting from RAM

You will need the BOOT jumpers both set to 0 to run this program in the default boot-from-FLASH configuration. To run the program from SRAM, you can modify the memory regions in `linker-stm32f103c8.ld` as follows:

```
REGION_ALIAS("VECTOR_SPACE",    SRAM)
REGION_ALIAS("CODE_SPACE",      SRAM)
REGION_ALIAS("RODATA_SPACE",    SRAM)
REGION_ALIAS("DATA_SPACE",      SRAM)
REGION_ALIAS("STACK_SPACE",     SRAM)
REGION_ALIAS("HEAP_SPACE",      SRAM)
```

and set both BOOT jumpers to 1.


## Hardware references

* [STM32F103C8 datasheet](https://www.st.com/resource/en/datasheet/stm32f103c8.pdf)
* [RM0008: STM32F1 reference manual](https://www.st.com/resource/en/reference_manual/cd00171190.pdf)
* [PM0056: Cortex-M3 programming manual](https://www.st.com/resource/en/programming_manual/cd00228163.pdf)
* [PM0075: STM32F1 flash programming manual](https://www.st.com/resource/en/programming_manual/cd00283419.pdf)


## Porting to other microcontrollers

(This is intended as a checklist for experienced developers.)

The framework in this project can be used for other STM32 microcontrollers with some changes in the following locations.

  * If the part isn't in the STM32F1 family, add a git submodule for the appropriate `cmsis-device` project and add it to `target_include_directories` in CMake.
  * Update the part-specific include in `project.h`.
  * Create a new `linker-PARTNAME.ld` for the new part with appropriate memory region addresses and sizes. Some parts may require new memory regions, e.g. for TCM or SDRAM.
  * Create a new `vectors-PARTNAME.s` for the new part. This can be largely automated by copying definitions from the `IRQn_Type` definition in the device header file.
  * Update the linker script and vector table filenames in CMake.
  * Update `CPUFLAGS` in CMake as appropriate for the core.
  * Update the clock configuration code in `startup.c`.

Non-STM32 microcontrollers which have CMSIS headers may be usable as well, if you're lucky.


## Licensing

This is free and unencumbered software released into the public domain. Refer to `LICENSE.md` for details.
