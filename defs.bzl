"""Root public API for rules_avr."""

load("//avr:defs.bzl", _AvrFirmwareInfo = "AvrFirmwareInfo", _avr_firmware = "avr_firmware", _avrdude_flash = "avrdude_flash")
load("//cc:defs.bzl", _avr_cc_binary = "avr_cc_binary")
load("//rust:defs.bzl", _avr_rust_binary = "avr_rust_binary")
load("//rust:rust_project.bzl", _avr_rust_project = "avr_rust_project")

AvrFirmwareInfo = _AvrFirmwareInfo
avr_cc_binary = _avr_cc_binary
avr_firmware = _avr_firmware
avr_rust_binary = _avr_rust_binary
avr_rust_project = _avr_rust_project
avrdude_flash = _avrdude_flash
