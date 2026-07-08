// Copyright 2026 The rules_avr authors
//

#ifndef BLINKIE_SRC_PULSE_LED_H_
#define BLINKIE_SRC_PULSE_LED_H_

#include <stdint.h>

// Initializes the LED and pulsing hardware. This should be called once at the
// beginning of the program.
void led_initialize(void);

// Toggles (pauses or resumes) LED pulsing.
void led_pulse_toggle(void);

#endif  // BLINKIE_SRC_PULSE_LED_H_
