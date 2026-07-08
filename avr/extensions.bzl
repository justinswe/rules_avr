# Copyright 2026 The rules_avr authors
#

"""Unified module extension for the AVR C++ and Rust toolchains."""

load("//avr:hosts.bzl", "SUPPORTED_HOSTS", "detect_host_key")
load("//cc/private:archives.bzl", "AVR_CANONICAL_DISTROS")  # buildifier: disable=bzl-visibility
load("//cc/private:repositories.bzl", "avr_cc_toolchains")  # buildifier: disable=bzl-visibility
load("//rust/private:repositories.bzl", "avr_rust_toolchains")  # buildifier: disable=bzl-visibility

_cc_toolchain_tag = tag_class(
    doc = "Configures the AVR C++ toolchain distribution.",
    attrs = {
        "distro": attr.string(
            doc = "The name of the AVR toolchain archive.",
            mandatory = False,
            values = AVR_CANONICAL_DISTROS,
        ),
        "custom_archives": attr.string_dict(
            doc = """A mapping of host architecture to custom archive URLs.

This can be used to override the default archive for specific architectures.

Syntax: `<url>[|sha256:<sha256>]`
""",
            mandatory = False,
            default = {},
        ),
    },
)

_rust_toolchain_tag = tag_class(
    doc = "Configures the AVR Rust toolchain.",
    attrs = {
        "analyzer_version": attr.string(
            doc = "The version of rust-analyzer to use. Defaults to 'nightly/<nightly_stamp>'.",
            default = "",
        ),
        "edition": attr.string(
            doc = "The default Rust edition for targets that do not specify one.",
            default = "2024",
        ),
        "nightly_stamp": attr.string(
            doc = "The nightly ISO date (YYYY-MM-DD) of the Rust compiler to use.",
            default = "2026-03-21",
        ),
        "src_sha256": attr.string(
            doc = "SHA256 of the rust-src-nightly.tar.xz archive for the given nightly_stamp.",
            default = "",
        ),
        "tools_sha256s": attr.string_dict(
            doc = """SHA256 checksums for nightly Rust host tool archives, all platforms.

Keys are '<stamp>/<archive>' (e.g. '2026-06-18/rustc-nightly-aarch64-apple-darwin.tar.xz').
""",
            default = {},
        ),
    },
)

def _avr_impl(module_ctx):
    host_key = detect_host_key(module_ctx)
    cc_tags = []
    rust_tags = []
    for mod in module_ctx.modules:
        cc_tags.extend(mod.tags.cc_toolchain)
        rust_tags.extend(mod.tags.rust_toolchain)

    if len(cc_tags) > 1:
        fail("rules_avr: at most one avr_toolchains.cc_toolchain tag may be declared.")
    if len(rust_tags) > 1:
        fail("rules_avr: at most one avr_toolchains.rust_toolchain tag may be declared.")

    if cc_tags:
        tag = cc_tags[0]
        avr_cc_toolchains(
            distro = tag.distro,
            custom_archives = tag.custom_archives,
            host_key = host_key,
        )

    if rust_tags:
        tag = rust_tags[0]
        if not tag.src_sha256:
            fail("rules_avr: avr_toolchains.rust_toolchain requires src_sha256 for hermetic rust-src downloads.")
        missing_sha256s = []
        for host in SUPPORTED_HOSTS:
            triple = SUPPORTED_HOSTS[host].rust_triple
            for tool in ["cargo", "clippy", "llvm-tools", "rust-std", "rustc", "rustfmt"]:
                key = "%s/%s-nightly-%s.tar.xz" % (tag.nightly_stamp, tool, triple)
                if key not in tag.tools_sha256s:
                    missing_sha256s.append(key)
        if missing_sha256s:
            fail("rules_avr: avr_toolchains.rust_toolchain missing tools_sha256s for: %s" % ", ".join(missing_sha256s))
        analyzer_version = tag.analyzer_version or ("nightly/" + tag.nightly_stamp)
        avr_rust_toolchains(
            nightly_stamp = tag.nightly_stamp,
            analyzer_version = analyzer_version,
            edition = tag.edition,
            host_key = host_key,
            src_sha256 = tag.src_sha256,
            tools_sha256s = tag.tools_sha256s,
        )

avr_toolchains = module_extension(
    implementation = _avr_impl,
    os_dependent = True,
    arch_dependent = True,
    tag_classes = {
        "cc_toolchain": _cc_toolchain_tag,
        "rust_toolchain": _rust_toolchain_tag,
    },
)
