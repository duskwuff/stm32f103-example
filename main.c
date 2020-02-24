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
    uint32_t cfgr = 0;
    SET_FIELD(cfgr, RCC_CFGR_SW,        0b00);      // stay on HSI
    SET_FIELD(cfgr, RCC_CFGR_HPRE,      0b0000);    // no AHB divider
    SET_FIELD(cfgr, RCC_CFGR_PPRE1,     0b100);     // APB1 = HCLK/2 (36 MHz)
    SET_FIELD(cfgr, RCC_CFGR_PPRE2,     0b000);     // APB2 = HCLK/1 (72 MHz)
    SET_FIELD(cfgr, RCC_CFGR_ADCPRE,    0b00);      // ADC = PCLK2/2
    SET_FIELD(cfgr, RCC_CFGR_PLLSRC,    0b1);       // PLLSRC = HSE
    SET_FIELD(cfgr, RCC_CFGR_PLLXTPRE,  0b0);       // no HSE divider
    SET_FIELD(cfgr, RCC_CFGR_PLLMULL,   9-1);       // PLLM = 9
    SET_FIELD(cfgr, RCC_CFGR_USBPRE,    0b1);       // USB = PLL/1.5 (48 MHz)
    SET_FIELD(cfgr, RCC_CFGR_MCO,       0b000);     // no MCO
    RCC->CFGR = cfgr;

    // Turn on HSE
    SET_FIELD(RCC->CR, RCC_CR_HSEON, 1);
    SPIN_UNTIL(GET_FIELD(RCC->CR, RCC_CR_HSERDY));

    // Turn on PLL
    SET_FIELD(RCC->CR, RCC_CR_PLLON, 1);
    SPIN_UNTIL(GET_FIELD(RCC->CR, RCC_CR_PLLRDY));

    // Enable FLASH wait states
    uint32_t acr = 0;
    SET_FIELD(acr,  FLASH_ACR_LATENCY,  2); // two wait states
    SET_FIELD(acr,  FLASH_ACR_PRFTBE,   1); // enable prefetch
    FLASH->ACR = acr;

    // Switch to PLL
    SET_FIELD(RCC->CFGR, RCC_CFGR_SW, 0b10); // PLL
    SPIN_UNTIL(GET_FIELD(RCC->CFGR, RCC_CFGR_SWS) == 0b10);

    // Configure SysTick to tick once every millisecond
    SysTick_Config(72*1000*1000 / 1000);
}

int main(void)
{
    // Enable PC13 (LED on bluepill, active low)
    SET_FIELD(RCC->APB2ENR, RCC_APB2ENR_IOPCEN, 1);
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
