#include <stm32f401xc.h>
#include <stdint.h>
#include "macros.h"

extern void * __isr_vector[];

volatile uint32_t tick_counter = 0;

void SysTick_Handler(void)
{
    tick_counter++;
}

void delay_ms(int ticks)
{
    uint32_t start_tick = tick_counter;
    while (tick_counter - start_tick < ticks) {
        __WFI();
    }
}

void SystemInit(void)
{
    // Relocate vector table -- required to run from RAM
    SCB->VTOR = (intptr_t) __isr_vector;

    // Enable FPU
    SCB->CPACR |= (0b11 << 22) | (0b11 << 20);

    // Power configuration -- enable VOS2 to support 84 MHz operation
    SET_FIELD(PWR->CR, PWR_CR_VOS, 0b10);

    // Configure for SYSCLK = 84 MHz (HSE = 25 MHz / 25 x 336 / 4)
    // This weird ratio is required to get 48 MHz for USB (336 / 7).
    RCC->PLLCFGR = 0
        | RCC_PLLCFGR_PLLSRC_HSE
        | (25   << RCC_PLLCFGR_PLLM_Pos)
        | (336  << RCC_PLLCFGR_PLLN_Pos)
        | (0b01 << RCC_PLLCFGR_PLLP_Pos)    // = /4
        | (7    << RCC_PLLCFGR_PLLQ_Pos)
        ;

    RCC->CFGR = 0
        | RCC_CFGR_HPRE_DIV1    // HCLK = SYSCLK  (84 MHz)
        | RCC_CFGR_PPRE1_DIV2   // PCLK1 = HCLK/2 (42 MHz)
        | RCC_CFGR_PPRE2_DIV1   // PCLK2 = HCLK   (84 MHz)
        ;

    // Turn on HSE
    RCC->CR |= RCC_CR_HSEON;
    SPIN_UNTIL(RCC->CR & RCC_CR_HSERDY);

    // Turn on PLL
    RCC->CR |= RCC_CR_PLLON;
    SPIN_UNTIL(RCC->CR & RCC_CR_PLLRDY);

    // Enable FLASH wait states, prefetch, and caching
    FLASH->ACR = 0
        | FLASH_ACR_DCEN
        | FLASH_ACR_ICEN
        | FLASH_ACR_PRFTEN
        | FLASH_ACR_LATENCY_2WS
        ;

    // Switch to PLL
    SET_FIELD(RCC->CFGR, RCC_CFGR_SW, 0b10); // PLL
    SPIN_UNTIL(GET_FIELD(RCC->CFGR, RCC_CFGR_SWS) == 0b10);

    SysTick_Config(84*1000*1000 / 1000);
}

int main(void)
{
    // Enable PC13 (LED on blackpill, active low)
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
    SET_FIELD(GPIOC->MODER, GPIO_MODER_MODER13, 0b01);  // general output

    // Blinky time
    for (;;) {
        GPIOC->BSRR = GPIO_BSRR_BR13;
        delay_ms(100);
        GPIOC->BSRR = GPIO_BSRR_BS13;
        delay_ms(900);
    }
}
