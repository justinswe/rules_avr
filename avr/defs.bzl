# Copyright 2026 The rules_avr authors
#

"""Public-facing rules for building and flashing AVR firmware."""

load("//avr/private:avrdude.bzl", _avrdude_flash = "avrdude_flash")
load("//avr/private:firmware.bzl", _AvrFirmwareInfo = "AvrFirmwareInfo", _avr_firmware = "avr_firmware")

AvrFirmwareInfo = _AvrFirmwareInfo
avr_firmware = _avr_firmware
avrdude_flash = _avrdude_flash
