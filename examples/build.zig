const std = @import("std");
const nvg = @import("nanovg/build.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("main", "main.zig");

    nvg.add(b, exe, "nanovg");
    exe.addIncludeDir("include");
    exe.linkSystemLibrary("epoxy");
    exe.linkSystemLibrary("glfw3");

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_step = b.step("run", "Run the example");
    run_step.dependOn(&exe.run().step);
}
