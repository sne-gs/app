const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const hugo_cmd = b.addSystemCommand(&.{ "hugo", "-s", "ui", "--minify" });
    try hugo_cmd.step.addWatchInput(b.path("ui/content"));
    try hugo_cmd.step.addWatchInput(b.path("ui/layouts"));

    const tailwind_cmd = b.addSystemCommand(&.{
        "tailwindcss",
        "-i",
        "ui/static/app.css",
        "-o",
        "ui/public/dist.css",
        "--minify",
    });
    try tailwind_cmd.step.addWatchInput(b.path("ui/static/app.css"));

    tailwind_cmd.step.dependOn(&hugo_cmd.step);

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
        .imports = &.{ .{ .name = "zs", .module = zs_mod }, .{ .name = "zh", .module = zh_mod } },
    });

    const exe = b.addExecutable(.{
        .name = "app",
        .root_module = root_mod,
    });

    exe.step.dependOn(&tailwind_cmd.step);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
