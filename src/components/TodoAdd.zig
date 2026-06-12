const std = @import("std");
const zh = @import("zh");

pub const TodoAdd = struct {
    pub fn render(self: *const TodoAdd, writer: *zh.FixedWriter) void {
        _ = self;
        const form = zh.element(writer, "form", .{
            .class = "flex gap-2 mt-4",
            .hx_post = "/add",
            .hx_target = ".todo-list",
            .hx_swap = "innerHTML",
        });
        defer form.close();

        _ = zh.element(writer, "input", .{
            .type = "text",
            .name = "title",
            .class = "input input-bordered flex-grow",
            .placeholder = "Add a new todo...",
        });

        const button = zh.element(writer, "button", .{
            .type = "submit",
            .class = "btn btn-primary",
        });
        defer button.close();
        zh.text(writer, "Add");
    }
};
