const std = @import("std");
const zh = @import("zh");
const sl = @import("sqlite");
const zs = @import("zs");
const TodoList = @import("components/TodoList.zig").TodoList;
const TodoApp = @import("components/TodoApp.zig").TodoApp;
const Todo = @import("models/Todo.zig").Todo;

pub const App = struct {
    db: *sl.Database,
    allocator: std.mem.Allocator,

    pub fn toggleHandler(self: *const App, ctx: *zs.Context(App)) !zs.Response {
        const id_str = ctx.req.params.get("id") orelse return zs.Response.badRequest("Missing id");
        const id = std.fmt.parseInt(i64, id_str, 10) catch return zs.Response.badRequest("Invalid id");
        const completed_str = ctx.req.query.get("completed") orelse return zs.Response.badRequest("Missing completed status");
        const completed = std.mem.eql(u8, completed_str, "true");
        const UpdateParams = struct { id: i64, completed: i64 };
        try self.db.exec("UPDATE todos SET completed = :completed WHERE id = :id", UpdateParams{
            .id = id,
            .completed = if (completed) 1 else 0,
        });
        var stmt = try self.db.prepare(struct { id: i64 }, Todo, "SELECT id, title, completed FROM todos WHERE id = :id");
        defer stmt.finalize();
        try stmt.bind(.{ .id = id });
        const row_opt = try stmt.step();
        const row = row_opt orelse return zs.Response.notFound();
        var out_buf: [4096]u8 = undefined;
        var writer = zh.FixedWriter{ .buffer = &out_buf };
        const item = @import("components/TodoItem.zig").TodoItem{ .todo = row };
        try item.render(&writer);
        return zs.Response.html(writer.buffer[0..writer.pos]);
    }

    pub fn addHandler(self: *const App, ctx: *zs.Context(App)) !zs.Response {
        var title_buf: [1024]u8 = undefined;
        const cl_str = ctx.req.headers.get("content-length") orelse return zs.Response.badRequest("Missing Content-Length");
        const content_length = try std.fmt.parseInt(usize, cl_str, 10);
        if (content_length > 4096) return zs.Response.badRequest("Payload too large");
        var body_buf: [1024]u8 = undefined;
        const body = body_buf[0..content_length];
        try ctx.req.body_reader.?.readSliceAll(body);
        const title_opt = try zs.form.getUrlEncodedValue(body, "title", &title_buf);
        const title = title_opt orelse return zs.Response.badRequest("Missing title");
        const Params = struct { title: sl.Text };
        try self.db.exec("INSERT INTO todos (title) VALUES (:title)", Params{ .title = .{ .data = title } });
        var out_buf: [4096]u8 = undefined;
        var writer = zh.FixedWriter{ .buffer = &out_buf };
        const list = TodoList{ .db = self.db };
        try list.render(&writer);
        return zs.Response.html(writer.buffer[0..writer.pos]);
    }

    pub fn deleteHandler(self: *const App, ctx: *zs.Context(App)) !zs.Response {
        const id_str = ctx.req.params.get("id") orelse return zs.Response.badRequest("Missing id");
        const id = std.fmt.parseInt(i64, id_str, 10) catch return zs.Response.badRequest("Invalid id");
        const Params = struct { id: i64 };
        try self.db.exec("DELETE FROM todos WHERE id = :id", Params{ .id = id });
        return zs.Response.text("");
    }

    pub fn rootHandler(self: *const App, ctx: *zs.Context(App)) !zs.Response {
        _ = ctx;
        var buf: [65536]u8 = undefined;
        var writer = zh.FixedWriter{ .buffer = &buf };
        const root = TodoApp{ .db = self.db };
        try root.render(&writer);
        return zs.Response.html(buf[0..writer.pos]);
    }
};
