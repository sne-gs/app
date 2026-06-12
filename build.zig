const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zio = b.dependency("zio", .{
        .target = target,
        .optimize = optimize,
    });
    const zio_mod = zio.module("zio");

    const sqlite = b.dependency("sqlite", .{});
    const sqlite_mod = sqlite.module("sqlite");

    const zs_dep = b.dependency("zs", .{
        .target = target,
    });
    const zs_mod = zs_dep.module("zs");

    const zh_dep = b.dependency("zh", .{
        .target = target,
    });
    const zh_mod = zh_dep.module("zh");

    const root_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sqlite", .module = sqlite_mod },
            .{ .name = "zio", .module = zio_mod },
            .{ .name = "zs", .module = zs_mod },
            .{ .name = "zh", .module = zh_mod },
        },
    });

    const exe = b.addExecutable(.{
        .name = "app",
        .root_module = root_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
