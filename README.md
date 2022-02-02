# NanoVG Zig

[NanoVG] is a simple vector graphics library for OpenGL, with an API modeled after the HTML5 canvas API.
This wrapper exposes NanoVG's functionality in a simple, type-safe Zig API.

## Usage

To add nanovg-zig to your project, first add this repository as a submodule, then add the following to your `build.zig`:

```zig
const nvg = @import("path/to/deps/nanovg/build.zig");

// ...

nvg.add(b, exe, "path/to/deps/nanovg");
```

You'll also need to provide a way to link to OpenGL. An example using [epoxy] can be found under `examples/`.

For windowing and calling to OpenGL, it is recommended to use [mach-glfw] and [zgl], respectively.

[NanoVG]: https://github.com/inniyah/nanovg
[epoxy]: https://github.com/anholt/libepoxy
[mach-glfw]: https://github.com/hexops/mach-glfw
[zgl]: https://github.com/ziglibs/zgl
