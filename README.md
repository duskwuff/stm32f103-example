# stm32f103-example

A tiny example project for the STM32F103.


## Requirements

* The [GNU ARM Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)
* [OpenOCD](http://openocd.org/)
* [Perl](https://www.perl.org/)

* A STM32F103C8 "Blue Pill" or compatible board
* A ST-Link debug adapter (or a compatible clone)


## Building and debugging

(Before you start: Make sure you have checked out the `STM32CubeF1` submodule. You can do this by running `git submodule update --init`.)

Set both BOOT jumpers to 0, attach your debugger to the computer and the target, then start OpenOCD:

```
openocd -f stlink-f1.cfg
```

Leave this running in one terminal, then launch:

```
arm-none-eabi-gdb program.elf
```

in another terminal.

You can now use `make` and `run` to run the program.


## Boot from FLASH / RAM

You will need the BOOT jumpers both set to 0 to run this program in the default boot-from-FLASH configuration. To run the program in SRAM, you can modify the memory regions in `ldscript.ld` as follows:

```
#define VEC_SPACE  SRAM
#define CODE_SPACE SRAM
#define LOAD_SPACE SRAM
```

and set both BOOT jumpers to 1.


## Hardware references

* [STM32F103C8 datasheet](https://www.st.com/resource/en/datasheet/stm32f103c8.pdf)
* [RM0008: STM32F1 reference manual](https://www.st.com/resource/en/reference_manual/cd00171190.pdf)
* [PM0056: Cortex-M3 programming manual](https://www.st.com/resource/en/programming_manual/cd00228163.pdf)
* [PM0075: STM32F1 flash programming manual](https://www.st.com/resource/en/programming_manual/cd00283419.pdf)
