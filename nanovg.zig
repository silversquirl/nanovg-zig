const std = @import("std");

pub const CreateFlags = packed struct {
    antialias: bool = false,
    stencil_strokes: bool = false,
    debug: bool = false,

    fn toCInt(self: CreateFlags) c_int {
        return @bitCast(std.meta.Int(.unsigned, @bitSizeOf(CreateFlags)), self);
    }
};

pub const Color = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,

    pub fn hex(rgba_hex: u32) Color {
        var c: [4]u8 = undefined;
        std.mem.writeIntBig(u32, &c, rgba_hex);
        return rgba(c[0], c[1], c[2], c[3]);
    }

    pub fn rgba(r: u8, g: u8, b: u8, a: u8) Color {
        return .{
            .r = @intToFloat(f32, r) / 0xff,
            .g = @intToFloat(f32, g) / 0xff,
            .b = @intToFloat(f32, b) / 0xff,
            .a = @intToFloat(f32, a) / 0xff,
        };
    }

    pub fn rgbaf(r: f32, g: f32, b: f32, a: f32) Color {
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    const hsla = nvgHSLA;
    extern fn nvgHSLA(h: f32, s: f32, l: f32, a: u8) Color;
};

pub const Paint = extern struct {
    xform: [6]f32,
    extent: [2]f32,
    radius: f32,
    feather: f32,
    inner_color: Color,
    outer_color: Color,
    image: Image,
};

pub const Winding = enum(c_int) {
    ccw = 1,
    cw = 2,
};

pub const Solidity = enum(c_int) {
    solid = 1,
    hole = 2,
};

pub const LineCap = enum(c_int) {
    butt,
    round,
    square,
    bevel,
    miter,
};

pub const Align = struct {
    h: Horizontal = .left,
    v: Vertical = .baseline,

    pub const Horizontal = enum { left, center, right };
    pub const Vertical = enum { top, middle, bottom, baseline };

    fn toCInt(self: Align) c_int {
        const h = @as(c_int, 1) << @enumToInt(self.h);
        const v = @as(c_int, 1) << @enumToInt(self.v);
        return h | (v << 3);
    }
};

pub const BlendFactor = enum(c_int) {
    zero = 1 << 0,
    one = 1 << 1,
    src_color = 1 << 2,
    one_minus_src_color = 1 << 3,
    dst_color = 1 << 4,
    one_minus_dst_color = 1 << 5,
    src_alpha = 1 << 6,
    one_minus_src_alpha = 1 << 7,
    dst_alpha = 1 << 8,
    one_minus_dst_alpha = 1 << 9,
    src_alpha_saturate = 1 << 10,
};

pub const CompositeOperation = enum(c_int) {
    source_over,
    source_in,
    source_out,
    atop,
    destination_over,
    destination_in,
    destination_out,
    destination_atop,
    lighter,
    copy,
    xor,
};

pub const CompositeOperationState = extern struct {
    src_rgb: c_int,
    dst_rgb: c_int,
    src_alpha: c_int,
    dst_alpha: c_int,
};

pub const Font = enum(c_int) { _ };

pub const GlyphPosition = extern struct {
    str: *const u8,
    x: f32,
    min_x: f32,
    max_x: f32,
};

pub const TextRow = extern struct {
    start: [*]const u8,
    end: [*]const u8,
    next: [*]const u8,
    width: f32,
    min_x: f32,
    max_x: f32,
};

pub const TextMetrics = struct {
    ascender: f32,
    descender: f32,
    line_height: f32,
};

pub const Image = enum(c_int) { _ };

pub const ImageFlags = packed struct {
    generate_mipmaps: bool = false,
    repeat_x: bool = false,
    repeat_y: bool = false,
    flip_y: bool = false,
    premultiplied: bool = false,
    nearest: bool = false,

    fn toCInt(self: ImageFlags) c_int {
        return @bitCast(std.meta.Int(.Unsigned, @bitSizeOf(ImageFlags)), self);
    }
};
pub const Context = opaque {
    pub fn createGl2(flags: CreateFlags) *Context {
        return nvgCreateGL2(flags.toCInt());
    }
    pub fn createGl3(flags: CreateFlags) *Context {
        return nvgCreateGL3(flags.toCInt());
    }
    pub fn createGles2(flags: CreateFlags) *Context {
        return nvgCreateGLES2(flags.toCInt());
    }
    pub fn createGles3(flags: CreateFlags) *Context {
        return nvgCreateGLES3(flags.toCInt());
    }
    extern fn nvgCreateGL2(flags: c_int) *Context;
    extern fn nvgCreateGL3(flags: c_int) *Context;
    extern fn nvgCreateGLES2(flags: c_int) *Context;
    extern fn nvgCreateGLES3(flags: c_int) *Context;

    pub const deleteGl2 = nvgDeleteGL2;
    pub const deleteGl3 = nvgDeleteGL3;
    pub const deleteGles2 = nvgDeleteGLES2;
    pub const deleteGles3 = nvgDeleteGLES3;
    extern fn nvgDeleteGL2(self: *Context) void;
    extern fn nvgDeleteGL3(self: *Context) void;
    extern fn nvgDeleteGLES2(self: *Context) void;
    extern fn nvgDeleteGLES3(self: *Context) void;

    pub const beginFrame = nvgBeginFrame;
    pub const cancelFrame = nvgCancelFrame;
    pub const endFrame = nvgEndFrame;
    extern fn nvgBeginFrame(self: *Context, win_width: f32, win_height: f32, dev_pixel_ratio: f32) void;
    extern fn nvgCancelFrame(self: *Context) void;
    extern fn nvgEndFrame(self: *Context) void;

    pub const globalCompositeOperation = nvgGlobalCompositeOperation;
    pub const globalCompositeBlendFunc = nvgGlobalCompositeBlendFunc;
    pub const globalCompositeBlendFuncSeparate = nvgGlobalCompositeBlendFuncSeparate;
    extern fn nvgGlobalCompositeOperation(self: *Context, op: CompositeOperation) void;
    extern fn nvgGlobalCompositeBlendFunc(self: *Context, src: BlendFactor, dst: BlendFactor) void;
    extern fn nvgGlobalCompositeBlendFuncSeparate(
        self: *Context,
        src_rgb: BlendFactor,
        dst_rgb: BlendFactor,
        src_alpha: BlendFactor,
        dst_alpha: BlendFactor,
    ) void;

    pub const save = nvgSave;
    pub const restore = nvgRestore;
    pub const reset = nvgReset;
    extern fn nvgSave(self: *Context) void;
    extern fn nvgRestore(self: *Context) void;
    extern fn nvgReset(self: *Context) void;

    pub fn shapeAntiAlias(self: *Context, enabled: bool) void {
        self.nvgShapeAntiAlias(@boolToInt(enabled));
    }
    extern fn nvgShapeAntiAlias(self: *Context, enabled: c_int) void;

    pub const strokeColor = nvgStrokeColor;
    pub const strokePaint = nvgStrokePaint;
    pub const fillColor = nvgFillColor;
    pub const fillPaint = nvgFillPaint;
    pub const miterLimit = nvgMiterLimit;
    pub const strokeWidth = nvgStrokeWidth;
    pub const lineCap = nvgLineCap;
    pub const lineJoin = nvgLineJoin;
    pub const globalAlpha = nvgGlobalAlpha;
    extern fn nvgStrokeColor(self: *Context, color: Color) void;
    extern fn nvgStrokePaint(self: *Context, paint: Paint) void;
    extern fn nvgFillColor(self: *Context, color: Color) void;
    extern fn nvgFillPaint(self: *Context, paint: Paint) void;
    extern fn nvgMiterLimit(self: *Context, limit: f32) void;
    extern fn nvgStrokeWidth(self: *Context, size: f32) void;
    extern fn nvgLineCap(self: *Context, cap: c_int) void;
    extern fn nvgLineJoin(self: *Context, join: c_int) void;
    extern fn nvgGlobalAlpha(self: *Context, alpha: f32) void;

    const resetTransform = nvgResetTransform;
    const transform = nvgTransform;
    const translate = nvgTranslate;
    const rotate = nvgRotate;
    const skewX = nvgSkewX;
    const skewY = nvgSkewY;
    const scale = nvgScale;
    extern fn nvgResetTransform(self: *Context) void;
    extern fn nvgTransform(self: *Context, a: f32, b: f32, c: f32, d: f32, e: f32, f: f32) void;
    extern fn nvgTranslate(self: *Context, x: f32, y: f32) void;
    extern fn nvgRotate(self: *Context, angle: f32) void;
    extern fn nvgSkewX(self: *Context, angle: f32) void;
    extern fn nvgSkewY(self: *Context, angle: f32) void;
    extern fn nvgScale(self: *Context, x: f32, y: f32) void;

    pub fn currentTransform(self: *Context) [6]f32 {
        var xform: [6]f32 = undefined;
        self.nvgCurrentTransform(&xform);
        return xform;
    }
    extern fn nvgCurrentTransform(self: *Context, xform: *[6]f32) void;

    pub fn createImage(self: *Context, filename: [*:0]const u8, flags: ImageFlags) Image {
        return self.nvgCreateImage(filename, flags.toCInt());
    }
    extern fn nvgCreateImage(self: *Context, filename: [*:0]const u8, flags: c_int) Image;

    pub fn createImageMem(self: *Context, flags: ImageFlags, data: []const u8) Image {
        return self.nvgCreateImageMem(flags.toCInt(), data.ptr, @intCast(c_int, data.len));
    }
    extern fn nvgCreateImageMem(self: *Context, flags: c_int, data: [*]const u8, len: c_int) Image;

    pub fn createImageRgba(self: *Context, w: u32, h: u32, flags: ImageFlags, data: []const u8) Image {
        std.debug.assert(data.len == w * h * 4);
        return self.nvgCreateImageRGBA(@intCast(c_int, w), @intCast(c_int, h), flags.toCInt(), data.ptr);
    }
    extern fn nvgCreateImageRGBA(self: *Context, w: c_int, h: c_int, flags: c_int, data: [*]const u8) Image;

    pub fn updateImage(self: *Context, img: Image, data: []const u8) void {
        const size = self.imageSize(img);
        std.debug.assert(data.len == size[0] * size[1] * 4);
        self.nvgUpdateImage(img, data.ptr);
    }
    extern fn nvgUpdateImage(self: *Context, img: Image, data: [*]const u8) void;

    pub fn imageSize(self: *Context, img: Image) [2]u32 {
        var w: c_int = undefined;
        var h: c_int = undefined;
        self.nvgImageSize(img, &w, &h);
        return .{ @intCast(u32, w), @intCast(u32, h) };
    }
    extern fn nvgImageSize(self: *Context, img: Image, w: *c_int, h: *c_int) void;

    pub const deleteImage = nvgDeleteImage;
    extern fn nvgDeleteImage(self: *Context, img: Image) void;

    pub const linearGradient = nvgLinearGradient;
    pub const boxGradient = nvgBoxGradient;
    pub const radialGradient = nvgRadialGradient;
    pub const imagePattern = nvgImagePattern;
    extern fn nvgLinearGradient(
        self: *Context,
        sx: f32,
        sy: f32,
        ex: f32,
        ey: f32,
        icol: Color,
        ocol: Color,
    ) Paint;
    extern fn nvgBoxGradient(
        self: *Context,
        x: f32,
        y: f32,
        w: f32,
        h: f32,
        r: f32,
        f: f32,
        icol: Color,
        ocol: Color,
    ) Paint;
    extern fn nvgRadialGradient(
        self: *Context,
        cx: f32,
        cy: f32,
        inr: f32,
        outr: f32,
        icol: Color,
        ocol: Color,
    ) Paint;
    extern fn nvgImagePattern(
        self: *Context,
        ox: f32,
        oy: f32,
        ex: f32,
        ey: f32,
        angle: f32,
        image: c_int,
        alpha: f32,
    ) Paint;

    pub const scissor = nvgScissor;
    pub const intersectScissor = nvgIntersectScissor;
    pub const resetScissor = nvgResetScissor;
    extern fn nvgScissor(self: *Context, x: f32, y: f32, w: f32, h: f32) void;
    extern fn nvgIntersectScissor(self: *Context, x: f32, y: f32, w: f32, h: f32) void;
    extern fn nvgResetScissor(self: *Context) void;

    pub const beginPath = nvgBeginPath;
    pub const moveTo = nvgMoveTo;
    pub const lineTo = nvgLineTo;
    pub const bezierTo = nvgBezierTo;
    pub const quadTo = nvgQuadTo;
    pub const arcTo = nvgArcTo;
    pub const closePath = nvgClosePath;
    pub const pathWinding = nvgPathWinding;
    pub const arc = nvgArc;
    extern fn nvgBeginPath(self: *Context) void;
    extern fn nvgMoveTo(self: *Context, x: f32, y: f32) void;
    extern fn nvgLineTo(self: *Context, x: f32, y: f32) void;
    extern fn nvgBezierTo(self: *Context, c1x: f32, c1y: f32, c2x: f32, c2y: f32, x: f32, y: f32) void;
    extern fn nvgQuadTo(self: *Context, cx: f32, cy: f32, x: f32, y: f32) void;
    extern fn nvgArcTo(self: *Context, x1: f32, y1: f32, x2: f32, y2: f32, radius: f32) void;
    extern fn nvgClosePath(self: *Context) void;
    extern fn nvgPathWinding(self: *Context, dir: Winding) void;
    extern fn nvgArc(self: *Context, cx: f32, cy: f32, r: f32, a0: f32, a1: f32, dir: Winding) void;

    pub fn barc(self: *Context, cx: f32, cy: f32, r: f32, a0: f32, a1: f32, dir: Winding, join: bool) void {
        self.nvgBarc(cx, cy, r, a0, a1, dir, @boolToInt(join));
    }
    extern fn nvgBarc(self: *Context, cx: f32, cy: f32, r: f32, a0: f32, a1: f32, dir: Winding, join: c_int) void;

    pub const rect = nvgRect;
    pub const roundedRect = nvgRoundedRect;
    pub const roundedRectVarying = nvgRoundedRectVarying;
    pub const ellipse = nvgEllipse;
    pub const circle = nvgCircle;
    pub const fill = nvgFill;
    pub const stroke = nvgStroke;
    extern fn nvgRect(self: *Context, x: f32, y: f32, w: f32, h: f32) void;
    extern fn nvgRoundedRect(self: *Context, x: f32, y: f32, w: f32, h: f32, r: f32) void;
    extern fn nvgRoundedRectVarying(
        self: *Context,
        x: f32,
        y: f32,
        w: f32,
        h: f32,
        rad_top_left: f32,
        rad_top_right: f32,
        rad_bottom_right: f32,
        rad_bottom_left: f32,
    ) void;
    extern fn nvgEllipse(self: *Context, cx: f32, cy: f32, rx: f32, ry: f32) void;
    extern fn nvgCircle(self: *Context, cx: f32, cy: f32, r: f32) void;
    extern fn nvgFill(self: *Context) void;
    extern fn nvgStroke(self: *Context) void;

    pub const createFont = nvgCreateFont;
    pub const createFontAtIndex = nvgCreateFontAtIndex;
    extern fn nvgCreateFont(self: *Context, name: [*:0]const u8, filename: [*:0]const u8) Font;
    extern fn nvgCreateFontAtIndex(
        self: *Context,
        name: [*:0]const u8,
        filename: [*:0]const u8,
        font_index: c_int,
    ) Font;

    pub fn createFontMem(
        self: *Context,
        name: [*:0]const u8,
        data: []const u8,
        free_data: bool,
    ) Font {
        return self.nvgCreateFontMem(name, data.ptr, @intCast(c_int, data.len), @boolToInt(free_data));
    }
    extern fn nvgCreateFontMem(
        self: *Context,
        name: [*:0]const u8,
        data: [*]const u8,
        ndata: c_int,
        free_data: c_int,
    ) Font;

    pub fn createFontMemAtIndex(
        self: *Context,
        name: [*:0]const u8,
        data: []const u8,
        free_data: bool,
        font_index: c_int,
    ) Font {
        return self.nvgCreateFontMem(
            name,
            data.ptr,
            @intCast(c_int, data.len),
            @boolToInt(free_data),
            font_index,
        );
    }
    extern fn nvgCreateFontMemAtIndex(
        self: *Context,
        name: [*:0]const u8,
        data: [*]const u8,
        ndata: c_int,
        free_data: c_int,
        font_index: c_int,
    ) Font;

    pub const findFont = nvgFindFont;
    pub const addFallbackFontId = nvgAddFallbackFontId;
    pub const addFallbackFont = nvgAddFallbackFont;
    pub const resetFallbackFontsId = nvgResetFallbackFontsId;
    pub const resetFallbackFonts = nvgResetFallbackFonts;
    extern fn nvgFindFont(self: *Context, name: [*:0]const u8) Font;
    extern fn nvgAddFallbackFontId(self: *Context, base: Font, fallback: Font) Font;
    extern fn nvgAddFallbackFont(self: *Context, base: [*:0]const u8, fallback: [*:0]const u8) Font;
    extern fn nvgResetFallbackFontsId(self: *Context, base: Font) void;
    extern fn nvgResetFallbackFonts(self: *Context, base: [*:0]const u8) void;

    pub const fontSize = nvgFontSize;
    pub const fontBlur = nvgFontBlur;
    pub const textLetterSpacing = nvgTextLetterSpacing;
    pub const textLineHeight = nvgTextLineHeight;
    extern fn nvgFontSize(self: *Context, size: f32) void;
    extern fn nvgFontBlur(self: *Context, blur: f32) void;
    extern fn nvgTextLetterSpacing(self: *Context, spacing: f32) void;
    extern fn nvgTextLineHeight(self: *Context, lineHeight: f32) void;

    pub fn textAlign(self: *Context, text_align: Align) void {
        return self.nvgTextAlign(text_align.toCInt());
    }
    extern fn nvgTextAlign(self: *Context, text_align: c_int) void;

    pub const fontFaceId = nvgFontFaceId;
    pub const fontFace = nvgFontFace;
    extern fn nvgFontFaceId(self: *Context, font: Font) void;
    extern fn nvgFontFace(self: *Context, font: [*:0]const u8) void;

    pub fn text(self: *Context, x: f32, y: f32, string: []const u8) f32 {
        return self.nvgText(x, y, string.ptr, string[string.len..].ptr);
    }
    extern fn nvgText(self: *Context, x: f32, y: f32, string: [*]const u8, end: [*]const u8) f32;

    pub fn textBox(self: *Context, x: f32, y: f32, wrap_width: f32, string: []const u8) void {
        self.nvgTextBox(x, y, wrap_width, string.ptr, string[string.len..].ptr);
    }
    extern fn nvgTextBox(
        self: *Context,
        x: f32,
        y: f32,
        wrap_width: f32,
        string: [*]const u8,
        end: [*]const u8,
    ) void;

    pub fn textBounds(
        self: *Context,
        x: f32,
        y: f32,
        string: []const u8,
        bounds: *[4]f32,
    ) f32 {
        self.nvgTextBounds(x, y, string.ptr, string[string.len..].ptr, bounds);
    }
    extern fn nvgTextBounds(
        self: *Context,
        x: f32,
        y: f32,
        string: [*]const u8,
        end: [*]const u8,
        bounds: *[4]f32,
    ) f32;

    pub fn textBoxBounds(
        self: *Context,
        x: f32,
        y: f32,
        wrap_width: f32,
        string: []const u8,
        bounds: *[4]f32,
    ) f32 {
        self.nvgTextBoxBounds(x, y, wrap_width, string.ptr, string[string.len..].ptr, bounds);
    }
    extern fn nvgTextBoxBounds(
        self: *Context,
        x: f32,
        y: f32,
        wrap_width: f32,
        string: [*]const u8,
        end: [*]const u8,
        bounds: *f32,
    ) void;

    pub fn textGlyphPositions(
        self: *Context,
        x: f32,
        y: f32,
        string: []const u8,
        positions: []GlyphPosition,
    ) usize {
        return @intCast(usize, self.nvgTextGlyphPositions(
            x,
            y,
            string.ptr,
            string[string.len..].ptr,
            positions.ptr,
            @intCast(c_int, positions.len),
        ));
    }
    extern fn nvgTextGlyphPositions(
        self: *Context,
        x: f32,
        y: f32,
        string: [*]const u8,
        end: [*]const u8,
        positions: [*]GlyphPosition,
        max_positions: c_int,
    ) c_int;

    pub fn textMetrics(self: *Context) TextMetrics {
        var metrics: TextMetrics = undefined;
        self.nvgTextMetrics(&metrics.ascender, &metrics.descender, &metrics.line_height);
        return metrics;
    }
    extern fn nvgTextMetrics(
        self: *Context,
        ascender: *f32,
        descender: *f32,
        lineh: *f32,
    ) void;

    pub fn textBreakLines(self: *Context, string: []const u8, wrap_width: f32, rows: []TextRow) usize {
        return @intCast(usize, self.nvgTextBreakLines(
            string.ptr,
            string[string.len..].ptr,
            wrap_width,
            rows.ptr,
            @intCast(c_int, rows.len),
        ));
    }
    extern fn nvgTextBreakLines(
        self: *Context,
        string: [*]const u8,
        end: [*]const u8,
        wrap_width: f32,
        rows: [*]TextRow,
        max_rows: c_int,
    ) c_int;
};

// TODO: wrap nvgTransform*, nvgDegToRad, nvgRadToDeg
// TODO: wrap nvglImage[From]Handle*
