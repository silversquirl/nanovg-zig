const std = @import("std");
const nvg = @import("nanovg");
const c = @cImport({
    @cInclude("GLFW/glfw3.h");
    @cInclude("epoxy/gl.h");
});

pub fn main() !void {
    _ = c.glfwInit();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    const win = c.glfwCreateWindow(800, 600, "Hello, world!", null, null) orelse {
        return error.GlfwInit;
    };
    defer c.glfwDestroyWindow(win);

    c.glfwMakeContextCurrent(win);
    const ctx = nvg.Context.createGl3(.{});
    defer ctx.deleteGl3();

    const font = ctx.createFontMem("Aileron", @embedFile("Aileron-Regular.otf"), false);

    while (c.glfwWindowShouldClose(win) == 0) {
        var width: c_int = undefined;
        var height: c_int = undefined;
        c.glfwGetWindowSize(win, &width, &height);
        var fb_width: c_int = undefined;
        c.glfwGetFramebufferSize(win, &fb_width, null);

        c.glViewport(0, 0, width, height);
        c.glClearColor(0, 0, 0, 0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        ctx.beginFrame(
            @intToFloat(f32, width),
            @intToFloat(f32, height),
            @intToFloat(f32, fb_width) / @intToFloat(f32, width),
        );

        ctx.beginPath();
        ctx.rect(50, 100, 200, 400);
        ctx.fillColor(nvg.Color.hex(0xff00ffff));
        ctx.fill();

        ctx.fillColor(nvg.Color.hex(0xffffffff));
        ctx.fontFaceId(font);
        ctx.fontSize(60);
        _ = ctx.text(70, 200, "Hello, world!");

        ctx.endFrame();
        c.glfwSwapBuffers(win);
        c.glfwWaitEvents();
    }
}
