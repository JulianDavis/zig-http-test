const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .x86_64,
            .os_tag = .linux,
            .abi = .musl,
        },
    });

    // I thought this would use ReleaseSmall when using `zig build` but it seems to still be building in Debug mode?
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall });

    // Build a static library from Zig source files
    // The LibraryOptions default to use LinkMode .static
    const lib = b.addLibrary(.{
        .name = "zhttp",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/http.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    lib.addIncludePath(b.path("include/"));
    b.installArtifact(lib);

    // Build a C executable that will import the static library
    const c_src_files = [_][]const u8{
        "src/main.c",
    };

    const c_flags = [_][]const u8{
        "-Wall",
        "-Wextra",
    };

    const exe = b.addExecutable(.{
        .name = "client",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    exe.root_module.addCSourceFiles(.{
        .files = &c_src_files,
        .flags = &c_flags,
    });

    exe.addIncludePath(b.path("include/"));
    exe.linkLibrary(lib);
    b.installArtifact(exe);
}
