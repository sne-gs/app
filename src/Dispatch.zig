const std = @import("std");
const zs = @import("zs");
const App = @import("App.zig").App;
const Handler = @import("Handler.zig").Handler;

pub const Dispatch = struct {
    pub const HandlerId = Handler;

    pub fn dispatch(id: HandlerId, ctx: *zs.Context(App)) ?zs.Response {
        std.log.debug("🎯 Dispatching handler: {any}", .{id}); // <-- LOG 1
        return switch (id) {
            .root => ctx.env.rootHandler(ctx),
            .add => ctx.env.addHandler(ctx),
            .delete => ctx.env.deleteHandler(ctx),
            .toggle => ctx.env.toggleHandler(ctx),
        } catch |err| {
            std.log.err("Handler execution failed: {any}", .{err});
            return null;
        };
    }
};
