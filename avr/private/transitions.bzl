# Copyright 2026 The rules_avr authors
#

"""Transitions for AVR targets."""

def _avr_transition_impl(settings, attr):
    mcu = attr.mcu
    return {
        "//command_line_option:platforms": "@rules_avr//avr/platform:" + attr.mcu + "_platform",
        "@rules_rust//rust/toolchain/channel:channel": "nightly",
        "@rules_rust//rust/settings:lto": "fat",
    }

avr_transition = transition(
    implementation = _avr_transition_impl,
    inputs = [],
    outputs = [
        "//command_line_option:platforms",
        "@rules_rust//rust/toolchain/channel:channel",
        "@rules_rust//rust/settings:lto",
    ],
)
