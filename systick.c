static volatile uint32_t tick_counter = 0;

void SysTick_Handler(void)
{
    tick_counter++;
}

void delay_ms(int ms)
{
    uint32_t start_tick = tick_counter;
    while (tick_counter - start_tick < ms)
    {
        __WFI();
    }
}
