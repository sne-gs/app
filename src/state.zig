// const std = @import("std");
// const zs = @import("zs");

// const MAX_BLOCKS = 64;
// const MAX_ID_LEN = 64;
// const MAX_TYPE_LEN = 32;
// const MAX_CONTENT_LEN = 4096;

// const Block = struct {
//     id: [MAX_ID_LEN]u8 = undefined,
//     id_len: usize = 0,
//     block_type: [MAX_TYPE_LEN]u8 = undefined,
//     type_len: usize = 0,
//     content: [MAX_CONTENT_LEN]u8 = undefined,
//     content_len: usize = 0,
//     lock_owner: [MAX_ID_LEN]u8 = undefined,
//     lock_owner_len: usize = 0,
//     has_lock: bool = false,
// };

// const ExportBlock = struct {
//     id: []const u8,
//     type: []const u8,
//     content: []const u8,
//     lock_owner: ?[]const u8,
// };

// pub const AppState = struct {
//     mutex: std.Thread.Mutex = .{},
//     blocks: [MAX_BLOCKS]Block = undefined,
//     block_count: usize = 0,
// };

// fn documentHandler(ctx: *zs.Context) zs.Response {
//     _ = ctx;
//     var buf: [65536]u8 = undefined;
//     var fbs = std.io.fixedBufferStream(&buf);
//     const writer = fbs.writer();
//     var app_state = .{};

//     app_state.mutex.lock();
//     defer app_state.mutex.unlock();

//     var export_blocks: [MAX_BLOCKS]ExportBlock = undefined;
//     for (app_state.blocks[0..app_state.block_count], 0..) |*block, i| {
//         export_blocks[i] = ExportBlock{
//             .id = block.id[0..block.id_len],
//             .type = block.block_type[0..block.type_len],
//             .content = block.content[0..block.content_len],
//             .lock_owner = if (block.has_lock)
//                 block.lock_owner[0..block.lock_owner_len]
//             else
//                 null,
//         };
//     }

//     std.json.stringify(export_blocks[0..app_state.block_count], .{}, writer) catch {
//         return zs.Response.init(.internal_server_error, "{\"error\":\"serialization failed\"}", "application/json");
//     };

//     const body = fbs.getWritten();
//     return zs.Response.init(.ok, body, "application/json");
