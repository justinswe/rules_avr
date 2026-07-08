# Copyright 2026 The rules_avr authors
#

"""AVR-specific build rules."""

load("@cc_compatibility_proxy//:proxy.bzl", _upstream_cc_binary = "cc_binary")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("//avr:defs.bzl", "avr_firmware")
load("//avr/private:binary.bzl", "COMMON_AVR_BINARY_ATTRS", "avr_binary")  # buildifier: disable=bzl-visibility

def _avr_cc_binary_impl(name, visibility, compatible_mcus, mcu, **kwargs):
    avr_binary(_upstream_cc_binary, name + "_bin", compatible_mcus, **kwargs)
    avr_firmware(
        name = name,
        src = ":" + name + "_bin",
        is_rust = False,
        mcu = mcu,
        visibility = visibility,
    )

avr_cc_binary = macro(
    doc = """Builds an AVR C/C++ binary and produces .elf and .hex outputs.

    Wraps cc_binary with AVR platform constraints and runs avr-objcopy to
    produce an Intel HEX file ready for flashing. Requires
    --platforms=//:avr_board (or equivalent) to select the target MCU.

    The intermediate binary is available as <name>_bin.
    """,
    inherit_attrs = _upstream_cc_binary,
    attrs = COMMON_AVR_BINARY_ATTRS,
    implementation = _avr_cc_binary_impl,
)
