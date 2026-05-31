const std = @import("std");
const zs = @import("zs");

const MyHandler = enum {
    hello,
};

fn helloHandler(ctx: *zs.Context) zs.Response {
    _ = ctx;
    return zs.Response.init(.ok, "Hello, World!", "text/html");
}

const MyDispatch = struct {
    pub const HandlerId = MyHandler;

    pub fn dispatch(id: HandlerId, ctx: *zs.Context) ?zs.Response {
        return switch (id) {
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
    server.mapStaticAssets("static");

    try server.addRoute(.GET, "/hello", .hello);

    try server.start(io);
}