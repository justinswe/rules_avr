# Copyright 2026 The rules_avr authors
#

"""Macros for building AVR binaries."""

COMMON_AVR_BINARY_ATTRS = {
    "target_compatible_with": None,
    "compatible_mcus": attr.string_list(
        doc = "Optional list of MCU names (e.g. ['attiny10', 'atmega328p']) this binary is compatible with. When non-empty, building for any other MCU will be marked incompatible.",
        default = [],
        configurable = False,
    ),
    "mcu": attr.string(
        doc = "The AVR MCU to build for (e.g. 'atmega328p').",
        mandatory = True,
    ),
}

def avr_binary(binary_rule, name, compatible_mcus, **kwargs):
    """Creates a binary target using binary_rule with AVR platform constraints.

    Args:
        binary_rule: The rule to invoke (e.g. cc_binary or rust_binary).
        name: Target name, already including any desired suffix (e.g. name + "_bin").
        compatible_mcus: List of MCU names to restrict compatibility to.
        **kwargs: Forwarded to binary_rule.
    """
    compat = [Label("@rules_avr//avr/platform:cpu_avr")]
    if compatible_mcus:
        compat = compat + select(dict(
            [(Label("@rules_avr//avr/platform:%s" % mcu), []) for mcu in compatible_mcus] +
            [("//conditions:default", [Label("@platforms//:incompatible")])],
        ))
    binary_rule(
        name = name,
        target_compatible_with = compat,
        **kwargs
    )
