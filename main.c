#include <stm32f103xb.h>
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

    // Configure for SYSCLK = 72 MHz (HSE = 8 MHz x 9)
    RCC->CFGR = 0
        | (0b00     << RCC_CFGR_SW_Pos)         // stay on HSI
        | (0b0000   << RCC_CFGR_HPRE_Pos)       // no AHB divider
        | (0b100    << RCC_CFGR_PPRE1_Pos)      // APB1 = HCLK/2 (36 MHz)
        | (0b000    << RCC_CFGR_PPRE2_Pos)      // APB2 = HCLK/1 (72 MHz)
        | (0b00     << RCC_CFGR_ADCPRE_Pos)     // ADC = PCLK2/2
        | (0b1      << RCC_CFGR_PLLSRC_Pos)     // PLLSRC = HSE
        | (0b0      << RCC_CFGR_PLLXTPRE_Pos)   // no HSE divider
        | ((9-1)    << RCC_CFGR_PLLMULL_Pos)    // PLLM = 9
        | (0b1      << RCC_CFGR_USBPRE_Pos)     // USB = PLL / 1.5 (48 MHz)
        | (0b000    << RCC_CFGR_MCO_Pos)        // no MCO
        ;

    // Turn on HSE
    RCC->CR |= RCC_CR_HSEON;
    SPIN_UNTIL(RCC->CR & RCC_CR_HSERDY);

    // Turn on PLL
    RCC->CR |= RCC_CR_PLLON;
    SPIN_UNTIL(RCC->CR & RCC_CR_PLLRDY);

    // Enable FLASH wait states
    FLASH->ACR = 0
        | (2    << FLASH_ACR_LATENCY_Pos)       // two wait states
        | FLASH_ACR_PRFTBE                      // enable prefetch
        ;

    // Switch to PLL
    SET_FIELD(RCC->CFGR, RCC_CFGR_SW, 0b10); // PLL
    SPIN_UNTIL(GET_FIELD(RCC->CFGR, RCC_CFGR_SWS) == 0b10);

    SysTick_Config(72*1000*1000 / 1000);
}

int main(void)
{
    // Enable PC13 (LED on bluepill, active low)
    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;
    SET_FIELD(GPIOC->CRH, GPIO_CRH_MODE13,  0b10); // slow output
    SET_FIELD(GPIOC->CRH, GPIO_CRH_CNF13,   0b00); // general output

    // Blinky time
    for (;;) {
        GPIOC->BSRR = GPIO_BSRR_BR13;
        delay_ms(100);
        GPIOC->BSRR = GPIO_BSRR_BS13;
        delay_ms(900);
    }
}
