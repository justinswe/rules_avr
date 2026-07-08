def _gcc_source_impl(ctx):
    ctx.download_and_extract(
        url = ctx.attr.gcc_url,
        sha256 = ctx.attr.gcc_sha256,
        stripPrefix = ctx.attr.gcc_strip_prefix,
    )
    ctx.download_and_extract(
        url = ctx.attr.gmp_url,
        sha256 = ctx.attr.gmp_sha256,
        stripPrefix = ctx.attr.gmp_strip_prefix,
        output = "gmp",
    )
    ctx.download_and_extract(
        url = ctx.attr.mpfr_url,
        sha256 = ctx.attr.mpfr_sha256,
        stripPrefix = ctx.attr.mpfr_strip_prefix,
        output = "mpfr",
    )
    ctx.download_and_extract(
        url = ctx.attr.mpc_url,
        sha256 = ctx.attr.mpc_sha256,
        stripPrefix = ctx.attr.mpc_strip_prefix,
        output = "mpc",
    )
    ctx.download_and_extract(
        url = ctx.attr.isl_url,
        sha256 = ctx.attr.isl_sha256,
        stripPrefix = ctx.attr.isl_strip_prefix,
        output = "isl",
    )
    ctx.file("BUILD.bazel", """
filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
""")

gcc_source = repository_rule(
    implementation = _gcc_source_impl,
    attrs = {
        "gcc_url": attr.string(mandatory = True),
        "gcc_sha256": attr.string(mandatory = True),
        "gcc_strip_prefix": attr.string(mandatory = True),
        "gmp_url": attr.string(mandatory = True),
        "gmp_sha256": attr.string(mandatory = True),
        "gmp_strip_prefix": attr.string(mandatory = True),
        "mpfr_url": attr.string(mandatory = True),
        "mpfr_sha256": attr.string(mandatory = True),
        "mpfr_strip_prefix": attr.string(mandatory = True),
        "mpc_url": attr.string(mandatory = True),
        "mpc_sha256": attr.string(mandatory = True),
        "mpc_strip_prefix": attr.string(mandatory = True),
        "isl_url": attr.string(mandatory = True),
        "isl_sha256": attr.string(mandatory = True),
        "isl_strip_prefix": attr.string(mandatory = True),
    },
)
