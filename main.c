#include <stdio.h>
#include <stdlib.h>

#include "systick.h"

int main(void)
{
    // Enable PC13 (LED on bluepill, active low)
    SET_FIELD(RCC->APB2ENR, RCC_APB2ENR_IOPCEN, 1);
    SET_FIELD(GPIOC->CRH, GPIO_CRH_MODE13, 0b10); // slow output
    SET_FIELD(GPIOC->CRH, GPIO_CRH_CNF13, 0b00);  // general output

    // Blinky time
    for (;;)
    {
        GPIOC->BSRR = GPIO_BSRR_BR13;
        delay_ms(100);
        GPIOC->BSRR = GPIO_BSRR_BS13;
        delay_ms(900);
    }
}
