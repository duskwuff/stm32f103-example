# stm32f401-example

A tiny example project for the STM32F401.


## Requirements

* The [GNU ARM Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)
* [OpenOCD](http://openocd.org/)
* [Perl](https://www.perl.org/)

* A STM32F401CC "Black Pill" or compatible board
* A ST-Link debug adapter (or a compatible clone)


## Building and debugging

(Before you start: Make sure you have checked out the `STM32CubeF4` submodule. You can do this by running `git submodule update --init`.)

Attach your debugger to the computer and the target, then start OpenOCD:

```
openocd -f stlink-f4.cfg
```

Leave this running in one terminal, then launch:

```
arm-none-eabi-gdb program.elf
```

in another terminal.

You can now use `make` and `run` to run the program.


## Boot from FLASH / RAM

To run the program in SRAM, you can modify the memory regions in `ldscript.ld` as follows:

```
#define VEC_SPACE  SRAM
#define CODE_SPACE SRAM
#define LOAD_SPACE SRAM
```

Booting this device from SRAM is a little awkward -- you will need to pull B2
high and press the BOOT0 button every time the device resets.


## Hardware references

* [STM32F401CC datasheet](https://www.st.com/resource/en/datasheet/stm32f401cc.pdf)
* [RM0368: STM32F4 reference manual](https://www.st.com/resource/en/reference_manual/dm00096844.pdf)
* [PM0214: Cortex-M4 programming manual](https://www.st.com/resource/en/programming_manual/dm00046982.pdf)
