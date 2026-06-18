const zs = @import("zs");
const HandlerId = @import("Handler.zig").HandlerId;

pub const routes = [_]zs.Route(HandlerId){
    .{ .method = .GET, .path = "/", .handler = .{ .global = .root } },
    .{ .method = .POST, .path = "/add", .handler = .{ .global = .add } },
    .{ .method = .DELETE, .path = "/delete/{id}", .handler = .{ .global = .delete } },
    .{ .method = .POST, .path = "/toggle/{id}", .handler = .{ .global = .toggle } },
};
