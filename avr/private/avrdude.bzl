# Copyright 2026 The rules_avr authors
#

"""Implementation of the avrdude_flash rule and its supporting avrdude_config rule."""

load("//avr/private:firmware.bzl", "AvrFirmwareInfo")

# avrdude_config ──────────────────────────────────────────────────────────────

AvrdudeConfigInfo = provider(
    doc = "Configuration for the avrdude_flash rule.",
    fields = {"part": "The avrdude part name (e.g. 'm328p', 'avr128db48'), or '' if unknown."},
)

def _avrdude_config_impl(ctx):
    return [AvrdudeConfigInfo(part = ctx.attr.part)]

avrdude_config = rule(
    doc = """Provides avrdude configuration via AvrdudeConfigInfo.

Instantiated in avr/private/BUILD to expose the MCU-platform-derived avrdude
part as a target that the avrdude_flash rule reads via its private _avrdude_config attr.
""",
    implementation = _avrdude_config_impl,
    attrs = {
        "part": attr.string(
            doc = "The avrdude part name (e.g. 'm328p', 'avr128db48'). May use select().",
            default = "",
        ),
    },
)

# avrdude_flash ───────────────────────────────────────────────────────────────

def _runfile_path(file, workspace_name):
    if file.short_path.startswith("../"):
        return file.short_path.removeprefix("../")
    return workspace_name + "/" + file.short_path

def _avrdude_impl(ctx):
    hex_file = ctx.attr.src[AvrFirmwareInfo].hex
    avrdude_part = ctx.attr.src[AvrFirmwareInfo].avrdude_part
    if not avrdude_part:
        fail("avrdude_flash: no avrdude part known for the selected MCU platform")

    avrdude_toolchain = ctx.toolchains["@rules_avr//avrdude:toolchain_type"].avrdude_info
    avrdude_bin = avrdude_toolchain.avrdude
    config_flag = ""
    runfiles = [hex_file, avrdude_bin]
    
    avrdude_path = _runfile_path(avrdude_bin, ctx.workspace_name)
    hex_path = _runfile_path(hex_file, ctx.workspace_name)
    
    if avrdude_toolchain.config:
        config_path = _runfile_path(avrdude_toolchain.config, ctx.workspace_name)
        config_flag = "-C \"${{RUNFILES_DIR}}/{config_path}\"".format(
            config_path = config_path,
        )
        runfiles.append(avrdude_toolchain.config)

    auto_flags = ["-p", avrdude_part, "-c", ctx.attr.programmer]

    quoted_flags = " ".join(['"' + f + '"' for f in auto_flags + ctx.attr.flags])

    script_content = """\
#!/usr/bin/env bash
set -euo pipefail

RUNFILES_DIR="${{RUNFILES_DIR:-${{0}}.runfiles}}"
HEX="${{RUNFILES_DIR}}/{hex_path}"
AVRDUDE="${{RUNFILES_DIR}}/{avrdude_path}"

echo "\"$AVRDUDE\" {config} {flags} \"-U\" \"flash:w:$HEX:i\" $@"
exec "$AVRDUDE" {config} {flags} "-U" "flash:w:$HEX:i" "$@"
""".format(
        hex_path = hex_path,
        avrdude_path = avrdude_path,
        config = config_flag,
        flags = quoted_flags,
    )

    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(output = script, content = script_content, is_executable = True)

    return [DefaultInfo(
        executable = script,
        runfiles = ctx.runfiles(files = runfiles),
    )]

avrdude_flash = rule(
    doc = """Generates a runnable target that flashes firmware using the host avrdude.

The avrdude binary must be available on the host system PATH at run time.

The following avrdude arguments are set automatically:
  -p <part>              inferred from the active MCU platform constraint
  -c <programmer>        from the mandatory programmer attribute
  -U flash:w:<hex>:i     the firmware hex file from the src target

The full command is printed before execution so it can be inspected or
copy-pasted for manual use.

Example:
    avr_cc_binary(name = "my_binary", srcs = ["main.c"])

    avrdude_flash(
        name = "flash",
        src = ":my_binary",
        programmer = "curiosity_nano",
    )

Then flash with: bazel run //:flash
Extra run-time flags can be appended via: bazel run //:flash -- -v
""",
    implementation = _avrdude_impl,
    attrs = {
        "src": attr.label(
            doc = "An avr_firmware (or avr_cc_binary / avr_rust_binary) target to flash.",
            providers = [AvrFirmwareInfo],
            mandatory = True,
        ),
        "programmer": attr.string(
            doc = "Programmer ID passed to avrdude as -c <programmer> (e.g. 'curiosity_nano', 'pkobn_updi').",
            mandatory = True,
        ),
        "flags": attr.string_list(
            doc = "Additional flags to pass to avrdude, inserted before the automatic -U flash write.",
            default = [],
        ),
    },
    executable = True,
    toolchains = ["@rules_avr//avrdude:toolchain_type"],
)
