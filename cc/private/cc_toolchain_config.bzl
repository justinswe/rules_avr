# Copyright 2026 The rules_avr authors
#

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "action_config", "feature", "flag_group", "flag_set", "tool", "tool_path")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("//cc:avr_action_names.bzl", "AVR_ACTION_NAMES")

def _join_tool_path(prefix, path):
    if prefix:
        return prefix + "/" + path
    return path

def _avr_cc_toolchain_config_impl(ctx):
    features = []

    mcu_flags = []
    if ctx.attr.mcu_flags:
        mcu_flags.append(
            flag_set(
                actions = [
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_link_executable,
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                ],
                flag_groups = [
                    flag_group(
                        flags = ctx.attr.mcu_flags,
                    ),
                ],
            ),
        )

    features.append(
        feature(
            name = "mcu",
            enabled = True,
            flag_sets = mcu_flags,
        ),
    )

    features.append(
        feature(
            name = "no_absolute_paths",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-no-canonical-prefixes",
                                "-fno-canonical-system-headers",
                            ],
                        ),
                    ],
                ),
            ],
        ),
    )

    features.append(
        feature(
            name = "opt_size",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["-Os"],
                        ),
                    ],
                ),
            ],
        ),
    )

    if ctx.attr.gcc_dir:
        gcc_path = ctx.attr.gcc_dir.files.to_list()[0].path
    else:
        gcc_path = ""

    if ctx.attr.binutils_dir:
        binutils_path = ctx.attr.binutils_dir.files.to_list()[0].path
    else:
        binutils_path = ""

    action_configs = [
        action_config(
            action_name = AVR_ACTION_NAMES.avr_objdump,
            enabled = True,
            tools = [tool(path = _join_tool_path(binutils_path, "bin/avr-objdump"))],
        ),
        action_config(
            action_name = AVR_ACTION_NAMES.avr_size,
            enabled = True,
            tools = [tool(path = _join_tool_path(binutils_path, "bin/avr-size"))],
        ),
        action_config(
            action_name = AVR_ACTION_NAMES.avr_nm,
            enabled = True,
            tools = [tool(path = _join_tool_path(binutils_path, "bin/avr-nm"))],
        ),
        action_config(
            action_name = ACTION_NAMES.objcopy_embed_data,
            enabled = True,
            tools = [tool(path = _join_tool_path(binutils_path, "bin/avr-objcopy"))],
        ),
    ]

    tool_paths = [
        tool_path(name = "gcc", path = _join_tool_path(gcc_path, "bin/avr-gcc")),
        tool_path(name = "cpp", path = _join_tool_path(gcc_path, "bin/avr-cpp")),
        tool_path(name = "ld", path = _join_tool_path(binutils_path, "bin/avr-ld")),
        tool_path(name = "ar", path = _join_tool_path(binutils_path, "bin/avr-ar")),
        tool_path(name = "nm", path = _join_tool_path(binutils_path, "bin/avr-nm")),
        tool_path(name = "objdump", path = _join_tool_path(binutils_path, "bin/avr-objdump")),
        tool_path(name = "strip", path = _join_tool_path(binutils_path, "bin/avr-strip")),
        tool_path(name = "objcopy", path = _join_tool_path(binutils_path, "bin/avr-objcopy")),
        tool_path(name = "gcov", path = _join_tool_path(gcc_path, "bin/avr-gcov")),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = features,
        action_configs = action_configs,
        toolchain_identifier = "avr-toolchain",
        host_system_name = "local",
        target_system_name = "avr",
        target_cpu = "avr",
        target_libc = "avr-libc",
        compiler = "avr-gcc",
        abi_version = "avr",
        abi_libc_version = "avr-libc",
        tool_paths = tool_paths,
    )

avr_cc_toolchain_config = rule(
    implementation = _avr_cc_toolchain_config_impl,
    attrs = {
        "mcu_flags": attr.string_list(),
        "gcc_dir": attr.label(cfg = "exec"),
        "binutils_dir": attr.label(cfg = "exec"),
    },
)
