# Copyright 2026 The rules_avr authors
#

"""Public-facing rules for building AVR Rust firmware."""

load("@rules_rust//rust:defs.bzl", _upstream_rust_binary = "rust_binary")
load("//avr:defs.bzl", "avr_firmware")
load("//avr/private:binary.bzl", "COMMON_AVR_BINARY_ATTRS", "avr_binary")  # buildifier: disable=bzl-visibility

def _avr_rust_binary_impl(name, visibility, compatible_mcus, mcu, **kwargs):
    avr_binary(
        _upstream_rust_binary,
        name + "_bin",
        compatible_mcus,
        **kwargs
    )
    avr_firmware(
        name = name,
        src = ":" + name + "_bin",
        is_rust = True,
        mcu = mcu,
        visibility = visibility,
    )

avr_rust_binary = macro(
    doc = """Builds an AVR Rust binary and produces .elf and .hex outputs.

    Wraps rust_binary with AVR platform constraints, nightly channel, and fat
    LTO, then runs avr-objcopy to produce an Intel HEX file ready for
    flashing. Requires --platforms=//:avr_board (or equivalent) to select the
    target MCU.

    The intermediate ELF is available as <name>_bin.
    """,
    inherit_attrs = _upstream_rust_binary,
    attrs = COMMON_AVR_BINARY_ATTRS,
    implementation = _avr_rust_binary_impl,
)
