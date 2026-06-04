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

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(allocator);

    var port: u16 = 3000;
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--port")) {
            if (i + 1 < args.len) {
                port = try std.fmt.parseInt(u16, args[i + 1], 10);
                i += 1;
            } else {
                std.debug.print("error: --port requires a value\n", .{});
                return error.InvalidArgs;
            }
        }
    }
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    const ServerType = zs.Server(MyDispatch);
    var server = try ServerType.init(allocator);
    server.setHost("0.0.0.0");
    server.setPort(port);
    server.mapStaticAssets("ui/public");

    try server.addRoute(.GET, "/hello", .hello);

    try server.start(io);
}
