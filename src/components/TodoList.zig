const std = @import("std");
const zh = @import("zh");
const sl = @import("sqlite");
const Todo = @import("../models/Todo.zig").Todo;
const TodoItem = @import("TodoItem.zig").TodoItem;

pub const TodoList = struct {
    db: *sl.Database,

    pub fn render(self: *const TodoList, writer: *zh.FixedWriter) !void {
        var stmt = try self.db.prepare(struct {}, Todo, "SELECT id, title, completed FROM todos ORDER BY id DESC");
        defer stmt.finalize();

        const div = zh.element(writer, "div", .{ .class = "space-y-2" });
        defer div.close();

        while (try stmt.step()) |row| {
            const item = TodoItem{ .todo = row };
            try item.render(writer);
        }
    }
};
