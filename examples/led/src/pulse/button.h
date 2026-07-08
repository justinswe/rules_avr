// Copyright 2026 The rules_avr authors
//

#ifndef BLINKIE_SRC_PULSE_BUTTON_H_
#define BLINKIE_SRC_PULSE_BUTTON_H_

// Callback invoked when the button is pressed.
typedef void (*button_callback_t)(void);

// Initializes the button hardware. The supplied callback is invoked (from
// interrupt context) each time a press is detected.
void button_initialize(button_callback_t on_press);

#endif  // BLINKIE_SRC_PULSE_BUTTON_H_
