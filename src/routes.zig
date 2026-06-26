const zs = @import("zs");
const HandlerId = @import("Handler.zig").HandlerId;

pub const routes = [_]zs.Route(HandlerId){
    .{ .method = .get, .path = "/", .handler = .{ .global = .root } },
    .{ .method = .post, .path = "/add", .handler = .{ .global = .add } },
    .{ .method = .delete, .path = "/delete/{id}", .handler = .{ .global = .delete } },
    .{ .method = .post, .path = "/toggle/{id}", .handler = .{ .global = .toggle } },
};
