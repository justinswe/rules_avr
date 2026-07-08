# Copyright 2026 The rules_avr authors
#

"""Toolchain configuration for avrdude."""

AvrdudeToolchainInfo = provider(
    doc = "Information about how to invoke avrdude.",
    fields = {
        "avrdude": "The avrdude executable.",
        "config": "Optional avrdude configuration file.",
    },
)

def _find_file(files, suffix):
    matches = [file for file in files if file.short_path.endswith(suffix)]
    if len(matches) != 1:
        fail("expected exactly one file ending in '{}', found {}".format(suffix, matches))
    return matches[0]

def _avrdude_toolchain_impl(ctx):
    if ctx.attr.is_foreign_cc:
        avrdude_files = ctx.attr.avrdude[DefaultInfo].files.to_list()
        avrdude_bin = _find_file(avrdude_files, "/bin/avrdude")
        avrdude_conf = _find_file(avrdude_files, "/etc/avrdude.conf")
    else:
        avrdude_bin = ctx.executable.avrdude
        avrdude_conf = ctx.file.config

    return [
        platform_common.ToolchainInfo(
            avrdude_info = AvrdudeToolchainInfo(
                avrdude = avrdude_bin,
                config = avrdude_conf,
            )
        )
    ]

avrdude_toolchain = rule(
    implementation = _avrdude_toolchain_impl,
    attrs = {
        "avrdude": attr.label(
            doc = "The avrdude executable or rules_foreign_cc target.",
            cfg = "exec",
            mandatory = True,
        ),
        "is_foreign_cc": attr.bool(
            doc = "Whether the avrdude target is a rules_foreign_cc target.",
            default = False,
        ),
        "config": attr.label(
            doc = "The avrdude configuration file (ignored if is_foreign_cc is True).",
            allow_single_file = True,
        ),
    },
)
