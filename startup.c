void Reset_Handler(void)
{
    SystemInit();
    __PROGRAM_START();
}

void SystemInit(void)
{
    // Relocate vector table -- this should generally be set by the MCU but
    // may be incorrect if running from a bootloader
    extern void *__isr_vector[];
    SCB->VTOR = (intptr_t)__isr_vector;

    // Configure for SYSCLK = 72 MHz (HSE = 8 MHz)
    RCC->CFGR = 0                                    //
                | FIELD_VAL(RCC_CFGR_SW, 0b00)       // stay on HSI for now
                | FIELD_VAL(RCC_CFGR_HPRE, 0b0000)   // no AHB divider
                | FIELD_VAL(RCC_CFGR_PPRE1, 0b100)   // APB1 = HCLK/2 (36 MHz)
                | FIELD_VAL(RCC_CFGR_PPRE2, 0b000)   // APB2 = HCLK/1 (72 MHz)
                | FIELD_VAL(RCC_CFGR_ADCPRE, 0b00)   // ADC = PCLK2/2
                | FIELD_VAL(RCC_CFGR_PLLSRC, 0b1)    // PLLSRC = HSE
                | FIELD_VAL(RCC_CFGR_PLLXTPRE, 0b0)  // no HSE divider
                | FIELD_VAL(RCC_CFGR_PLLMULL, 9 - 1) // PLLM = 9
                | FIELD_VAL(RCC_CFGR_USBPRE, 0b1)    // USB = PLL/1.5 (48 MHz)
                | FIELD_VAL(RCC_CFGR_MCO, 0b000)     // no MCO
        ;

    // Turn on HSE
    SET_FIELD(RCC->CR, RCC_CR_HSEON, 1);
    SPIN_UNTIL(GET_FIELD(RCC->CR, RCC_CR_HSERDY));

    // Turn on PLL
    SET_FIELD(RCC->CR, RCC_CR_PLLON, 1);
    SPIN_UNTIL(GET_FIELD(RCC->CR, RCC_CR_PLLRDY));

    // Enable FLASH wait states
    FLASH->ACR = 0                                 //
                 | FIELD_VAL(FLASH_ACR_LATENCY, 2) // two wait states
                 | FIELD_VAL(FLASH_ACR_PRFTBE, 1)  // enable prefetch
        ;

    // Switch to PLL
    SET_FIELD_SHIFTED(RCC->CFGR, RCC_CFGR_SW, RCC_CFGR_SW_PLL);
    SPIN_UNTIL((RCC->CFGR & RCC_CFGR_SWS) == RCC_CFGR_SWS_PLL);

    // Configure SysTick to tick once every millisecond
    SysTick_Config(72 * 1000);
}
