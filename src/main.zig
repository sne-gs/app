const std = @import("std");
const sl = @import("sqlite");
const zio = @import("zio");
const zs = @import("zs");
const App = @import("App.zig").App;
const Dispatch = @import("Dispatch.zig").Dispatch;
const routes = @import("routes.zig").routes;

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);
    var port: u16 = 3558;
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
    const rt = try zio.Runtime.init(std.heap.smp_allocator, .{
        .executors = @enumFromInt(10),
    });
    defer rt.deinit();
    const io = rt.io();
    var db = try sl.Database.open(.{ .path = "todos.db" });
    defer db.close();
    try db.exec("CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, completed INTEGER NOT NULL DEFAULT 0)", .{});
    const app = App{ .db = &db, .allocator = allocator };
    const ServerType = zs.Server(Dispatch, App, &routes);
    var server = try ServerType.init(app, allocator);
    server.setHost("0.0.0.0");
    server.setPort(port);
    var group: std.Io.Group = .init;
    defer group.cancel(io);
    try server.start(io, &group);
    try group.await(io);
}
