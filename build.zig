const std = @import("std");

pub fn add(b: *std.build.Builder, step: *std.build.LibExeObjStep) void {
    const nanovg_path = std.fs.path.dirname(@src().file) orelse ".";

    step.linkLibC();
    step.addIncludePath(b.fmt("{s}/deps/nanovg/src/", .{nanovg_path}));
    step.addIncludePath(b.fmt("{s}/deps/", .{nanovg_path}));

    step.defineCMacroRaw("NANOVG_GL3");
    step.addCSourceFile(b.fmt("{s}/deps/nanovg/src/nanovg.c", .{nanovg_path}), &.{ "-Wall", "-Werror" });
    step.addCSourceFile(b.fmt("{s}/deps/nanovg/src/nanovg_gl.c", .{nanovg_path}), &.{ "-Wall", "-Werror" });

    step.addPackagePath("nanovg", b.fmt("{s}/nanovg.zig", .{nanovg_path}));
}
