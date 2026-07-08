def _exec_filegroup_impl(ctx):
    return [DefaultInfo(files = depset(transitive = [dep[DefaultInfo].files for dep in ctx.attr.srcs]))]

exec_filegroup = rule(
    implementation = _exec_filegroup_impl,
    attrs = {
        "srcs": attr.label_list(cfg = "exec"),
    },
)
