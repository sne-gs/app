const std = @import("std");
const zs = @import("zs");
const App = @import("App.zig").App;
const HandlerId = @import("Handler.zig").HandlerId;

pub const Dispatch = struct {
    pub fn dispatch(id: HandlerId, ctx: *zs.Context(App, void)) zs.Response {
        return switch (id.global) {
            .root => ctx.env.rootHandler(ctx),
            .add => ctx.env.addHandler(ctx),
            .delete => ctx.env.deleteHandler(ctx),
            .toggle => ctx.env.toggleHandler(ctx),
        } catch |err| {
            std.log.err("Handler execution failed: {any}", .{err});
            return zs.Response.status(.not_found).static("404 Not found.");
        };
    }
};

pub const Pipe = zs.Pipeline(App, HandlerId)
    .group(.global, void, Dispatch, .{})
    .build();
