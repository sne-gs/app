const std = @import("std");
const zs = @import("zs");
const App = @import("App.zig").App;
const Handler = @import("Handler.zig").Handler;

pub const Dispatch = struct {
    pub const HandlerId = Handler;

    pub fn dispatch(id: HandlerId, ctx: *zs.Context(App)) ?zs.Response {
        return switch (id) {
            .root => ctx.env.rootHandler(ctx) catch |err| {
                std.log.err("root error: {}\n", .{err});
                return zs.Response.init(.internal_server_error, "Internal Error", "text/html");
            },
            .add => ctx.env.addHandler(ctx) catch |err| {
                std.log.err("add error: {}\n", .{err});
                return zs.Response.init(.internal_server_error, "Internal Error", "text/html");
            },
            .delete => ctx.env.deleteHandler(ctx) catch |err| {
                std.log.err("delete error: {}\n", .{err});
                return zs.Response.init(.internal_server_error, "Internal Error", "text/html");
            },
            .toggle => ctx.env.toggleHandler(ctx) catch |err| {
                std.log.err("toggle error: {}\n", .{err});
                return zs.Response.init(.internal_server_error, "Internal Error", "text/html");
            },
        };
    }
};
