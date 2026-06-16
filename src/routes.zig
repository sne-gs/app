const zs = @import("zs");
const Handler = @import("Handler.zig").Handler;

pub const routes = [_]zs.Route(Handler){
    .{ .method = .GET, .path = "/", .handler = .root },
    .{ .method = .POST, .path = "/add", .handler = .add },
    .{ .method = .DELETE, .path = "/delete/{id}", .handler = .delete },
    .{ .method = .POST, .path = "/toggle/{id}", .handler = .toggle },
};
