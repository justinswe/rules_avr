# Copyright 2026 The rules_avr authors
#

"""Implementation of the avr_firmware rule."""

load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc:find_cc_toolchain.bzl", "CC_TOOLCHAIN_ATTRS", "find_cc_toolchain", "use_cc_toolchain")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("//cc:avr_action_names.bzl", "AVR_ACTION_NAMES")

load("//avr/private:mcus.bzl", "AVR_MCUS")

AvrFirmwareInfo = provider(
    doc = "Provides the ELF, Intel HEX, disassembly, and size report outputs of an avr_firmware target.",
    fields = {
        "asm": "The disassembled listing (.asm) output file.",
        "elf": "The .elf output file.",
        "hex": "The Intel HEX (.hex) output file.",
        "size": "The avr-size report (.size) output file.",
        "avrdude_part": "The avrdude part name mapped from the mcu.",
    },
)

def _avr_transition_impl(_settings, attr):
    out = {
        "//command_line_option:platforms": "@rules_avr//avr/platform:" + attr.mcu + "_platform",
        "//rust/config:avr": True,
        "@rules_rust//rust/toolchain/channel:channel": "nightly",
        "@rules_rust//rust/settings:lto": "fat",
    }
    return out

_avr_transition = transition(
    implementation = _avr_transition_impl,
    inputs = [],
    outputs = [
        "//command_line_option:platforms",
        "//rust/config:avr",
        "@rules_rust//rust/toolchain/channel:channel",
        "@rules_rust//rust/settings:lto",
    ],
)

def _avr_firmware_impl(ctx):
    toolchain = find_cc_toolchain(ctx)
    src = ctx.file.src
    elf = ctx.actions.declare_file(ctx.label.name + ".elf")
    ctx.actions.symlink(output = elf, target_file = src)
    asm = ctx.actions.declare_file(ctx.label.name + ".asm")
    hex = ctx.actions.declare_file(ctx.label.name + ".hex")
    size = ctx.actions.declare_file(ctx.label.name + ".size")
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = toolchain,
    )
    tool_inputs = toolchain.all_files.to_list()
    objcopy = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.objcopy_embed_data,
    )
    ctx.actions.run(
        inputs = [src] + tool_inputs,
        outputs = [hex],
        executable = objcopy,
        arguments = ["-O", "ihex", src.path, hex.path],
        mnemonic = "AvrObjcopy",
        progress_message = "Generating AVR hex {} from {}".format(hex.path, src.path),
    )
    avr_objdump = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = AVR_ACTION_NAMES.avr_objdump,
    )
    ctx.actions.run_shell(
        inputs = [src] + tool_inputs,
        outputs = [asm],
        command = "{avr_objdump} -d -S {elf} > {out}".format(
            avr_objdump = avr_objdump,
            elf = src.path,
            out = asm.path,
        ),
        mnemonic = "AvrObjdump",
        progress_message = "Disassembling AVR ELF {}".format(src.path),
    )
    avr_size = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = AVR_ACTION_NAMES.avr_size,
    )
    ctx.actions.run_shell(
        inputs = [src] + tool_inputs,
        outputs = [size],
        command = "{avr_size} {elf} > {out}".format(
            avr_size = avr_size,
            elf = src.path,
            out = size.path,
        ),
        mnemonic = "AvrSize",
        progress_message = "Computing AVR size for {}".format(src.path),
    )
    avrdude_part = AVR_MCUS[ctx.attr.mcu].avrdude_part
    return [
        DefaultInfo(files = depset([elf, asm, hex, size])),
        AvrFirmwareInfo(asm = asm, elf = elf, hex = hex, size = size, avrdude_part = avrdude_part),
    ]

avr_firmware = rule(
    implementation = _avr_firmware_impl,
    attrs = {
        "src": attr.label(
            doc = "The ELF binary to convert to Intel HEX format.",
            allow_single_file = True,
            mandatory = True,
        ),
        "is_rust": attr.bool(
            doc = "Whether to apply the Rust/AVR transition to src.",
            default = False,
        ),
        "mcu": attr.string(
            doc = "The AVR MCU to build for (e.g. 'atmega328p').",
            mandatory = True,
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
    } | CC_TOOLCHAIN_ATTRS,
    toolchains = use_cc_toolchain(),
    fragments = ["cpp"],
    cfg = _avr_transition,
)
