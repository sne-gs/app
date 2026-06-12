const std = @import("std");
const zh = @import("zh");
const sl = @import("sqlite");
const Todo = @import("../models/Todo.zig").Todo;

pub const TodoItem = struct {
    todo: Todo,

    pub fn render(self: *const TodoItem, writer: *zh.FixedWriter) !void {
        const completed = self.todo.isCompleted();
        const title = self.todo.title.data;

        var class_buf: [128]u8 = undefined;
        const base = "todo flex items-center gap-3 p-3 bg-base-100 rounded-lg shadow-sm border border-base-200";
        const class_str = if (completed)
            try std.fmt.bufPrint(&class_buf, "{s} opacity-75", .{base})
        else
            base;

        const todo_div = zh.element(writer, "div", .{ .class = class_str });
        defer todo_div.close();

        {
            var toggle_url_buf: [64]u8 = undefined;
            const new_completed = if (completed) "false" else "true";
            const toggle_url = try std.fmt.bufPrint(&toggle_url_buf, "/toggle/{d}?completed={s}", .{ self.todo.id, new_completed });
            _ = zh.element(writer, "input", .{
                .type = "checkbox",
                .class = "checkbox checkbox-primary checkbox-sm",
                .hx_post = toggle_url,
                .hx_target = "closest .todo",
                .hx_swap = "outerHTML",
                .checked = if (completed) "checked" else null,
            });
        }

        {
            const span_class = if (completed) "flex-1 line-through text-gray-500" else "flex-1";
            const title_span = zh.element(writer, "span", .{ .class = span_class });
            zh.text(writer, title);
            title_span.close();
        }

        {
            var delete_url_buf: [64]u8 = undefined;
            const delete_url = try std.fmt.bufPrint(&delete_url_buf, "/delete?id={d}", .{self.todo.id});
            const del_button = zh.element(writer, "button", .{
                .class = "btn btn-error btn-xs",
                .hx_delete = delete_url,
                .hx_target = "closest .todo",
                .hx_swap = "outerHTML",
            });
            zh.text(writer, "Delete");
            del_button.close();
        }
    }
};
