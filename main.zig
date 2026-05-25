const std = @import("std");
const zs = @import("zs");

const index_html = @embedFile("static/index.html");
const output_css = @embedFile("static/output.css");

const MyHandler = enum {
    app,
    style_css,
    hello,
};

fn appHandler(ctx: *zs.Context) zs.Response {
    _ = ctx;
    return zs.Response.init(.ok, index_html, "text/html");
}

fn styleCssHandler(ctx: *zs.Context) zs.Response {
    _ = ctx;
    return zs.Response.init(.ok, output_css, "text/css");
}

fn helloHandler(ctx: *zs.Context) zs.Response {
    _ = ctx;
    return zs.Response.init(.ok, "<p class=\"text-lg text-success\">Hello, friend!</p>", "text/html");
}

const MyDispatch = struct {
    pub const HandlerId = MyHandler;

    pub fn dispatch(id: HandlerId, ctx: *zs.Context) ?zs.Response {
        return switch (id) {
            .app => appHandler(ctx),
            .style_css => styleCssHandler(ctx),
            .hello => helloHandler(ctx),
        };
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    const ServerType = zs.Server(MyDispatch);
    var server = try ServerType.init(allocator);
    server.setHost("0.0.0.0");
    server.setPort(3000);
    server.setIndex("static/index.html");

    try server.addRoute(.GET, "/app", .app);
    try server.addRoute(.GET, "/style.css", .style_css);
    try server.addRoute(.GET, "/hello", .hello);

    try server.start(io);
}