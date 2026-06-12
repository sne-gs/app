const std = @import("std");
const zh = @import("zh");
const sl = @import("sqlite");
const TodoList = @import("TodoList.zig").TodoList;
const TodoAdd = @import("TodoAdd.zig").TodoAdd;

pub const TodoApp = struct {
    db: *sl.Database,

    pub fn render(self: *const TodoApp, writer: *zh.FixedWriter) !void {
        writer.write("<!doctype html>");
        const html = zh.element(writer, "html", .{ .class = "h-full" });
        {
            const head = zh.element(writer, "head", .{});
            _ = zh.element(writer, "meta", .{ .name = "viewport", .content = "width=device-width, initial-scale=1" });
            const tailwind = zh.element(writer, "script", .{ .src = "https://cdn.tailwindcss.com" });
            tailwind.close();
            _ = zh.element(writer, "link", .{ .href = "https://cdn.jsdelivr.net/npm/daisyui@4.12.10/dist/full.css", .rel = "stylesheet" });
            const htmx = zh.element(writer, "script", .{ .src = "https://unpkg.com/htmx.org@2.0.2" });
            htmx.close();
            head.close();
        }
        {
            const body = zh.element(writer, "body", .{ .class = "bg-base-200 p-4 min-h-full" });
            {
                const container = zh.element(writer, "div", .{ .class = "max-w-2xl mx-auto" });
                {
                    const title = zh.element(writer, "h1", .{ .class = "text-3xl mb-4" });
                    zh.text(writer, "hi there");
                    title.close();
                    const subtitle = zh.element(writer, "p", .{ .class = "mb-3" });
                    zh.text(writer, "here's a todo app");
                    subtitle.close();
                    const card = zh.element(writer, "div", .{ .class = "card bg-base-100 shadow-xl" });
                    {
                        const card_body = zh.element(writer, "div", .{ .class = "card-body" });
                        {
                            const h1 = zh.element(writer, "h1", .{ .class = "card-title text-2xl mb-4 text-center w-full justify-center" });
                            zh.text(writer, "Todo App");
                            h1.close();
                        }
                        {
                            const list_div = zh.element(writer, "div", .{ .class = "todo-list" });
                            const list = TodoList{ .db = self.db };
                            try list.render(writer);
                            list_div.close();
                        }
                        const add = TodoAdd{};
                        add.render(writer);
                        card_body.close();
                    }
                    card.close();
                    const description = zh.element(writer, "p", .{ .class = "my-4" });
                    zh.text(writer, "it's written in zig, here's the source code:");
                    description.close();
                    const link = zh.element(writer, "a", .{ .class = "link link-primary", .href = "https://codeberg.org/snegs/app/src/branch/main/src/main.zig" });
                    zh.text(writer, "link");
                    link.close();
                }
                container.close();
            }
            body.close();
        }
        html.close();
    }
};
