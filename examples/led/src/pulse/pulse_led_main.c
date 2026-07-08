// Copyright 2026 The rules_avr authors
//

#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/sleep.h>

#include "src/pulse/button.h"
#include "src/pulse/led.h"

int main(void) {
    led_initialize();
    button_initialize(led_pulse_toggle);

    // Enable sleep in idle mode when the SLEEP instruction is executed. This
    // will keep the timer hardware still running while the CPU is sleeping.
    SLPCTRL.CTRLA = SLPCTRL_SMODE_IDLE_gc;
    SLPCTRL.CTRLA |= SLPCTRL_SEN_bm;

    sei();
    while (1) {
        sleep_cpu();
    }
}
