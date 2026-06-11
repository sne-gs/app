const std = @import("std");
const zs = @import("zs");
const zh = @import("zh");
const sl = @import("sqlite");

const Todo = struct {
    id: i64,
    title: sl.Text,
    completed: i64,
};

const TodoApp = struct {
    db: *sl.Database,

    fn renderList(self: *const TodoApp, writer: *zh.FixedWriter) !void {
        var stmt = try self.db.prepare(struct {}, Todo, "SELECT id, title, completed FROM todos ORDER BY id DESC");
        defer stmt.finalize();
        const div = zh.element(writer, "div", .{ .class = "todo-list" });
        defer div.close();
        while (try stmt.step()) |row| {
            try self.renderTodoItem(writer, row);
        }
    }

    fn renderTodoItem(self: *const TodoApp, writer: *zh.FixedWriter, row: Todo) !void {
        _ = self;
        const completed = row.completed != 0;
        const title = row.title.data;
        const todo_div = zh.element(writer, "div", .{ .class = if (completed) "todo completed" else "todo" });
        defer todo_div.close();
        var toggle_url_buf: [64]u8 = undefined;
        const new_completed = if (completed) "false" else "true";
        const toggle_url = try std.fmt.bufPrint(&toggle_url_buf, "/toggle/{d}?completed={s}", .{ row.id, new_completed });
        const checkbox = zh.element(writer, "input", .{
            .type = "checkbox",
            .hx_post = toggle_url,
            .hx_target = "closest .todo",
            .hx_swap = "outerHTML",
            .checked = if (completed) "checked" else null,
        });
        defer checkbox.close();
        zh.text(writer, title);
        var delete_url_buf: [64]u8 = undefined;
        const delete_url = try std.fmt.bufPrint(&delete_url_buf, "/delete?id={d}", .{row.id});
        const del = zh.element(writer, "button", .{
            .hx_delete = delete_url,
            .hx_target = "closest .todo",
            .hx_swap = "outerHTML",
        });
        defer del.close();
        zh.text(writer, "Delete");
    }

    fn renderAdd(self: *const TodoApp, writer: *zh.FixedWriter) void {
        _ = self;
        const form = zh.element(writer, "form", .{
            .hx_post = "/add",
            .hx_target = ".todo-list",
            .hx_swap = "innerHTML",
        });
        defer form.close();
        const input = zh.element(writer, "input", .{ .type = "text", .name = "title", .placeholder = "Add a new todo..." });
        defer input.close();
        const button = zh.element(writer, "button", .{ .type = "submit" });
        defer button.close();
        zh.text(writer, "Add");
    }

    pub fn toggleHandler(self: *const TodoApp, ctx: *zs.Context(TodoApp)) !zs.Response {
        const id_str = ctx.request.params.get("id") orelse {
            return zs.Response.init(.bad_request, "Missing id", "text/plain");
        };
        const id = std.fmt.parseInt(i64, id_str, 10) catch {
            return zs.Response.init(.bad_request, "Invalid id", "text/plain");
        };
        const completed_str = ctx.request.query.get("completed") orelse {
            return zs.Response.init(.bad_request, "Missing completed status", "text/plain");
        };
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
        const row = row_opt orelse return zs.Response.init(.not_found, "Todo not found", "text/plain");
        var out_buf: [4096]u8 = undefined;
        var writer = zh.FixedWriter{ .buffer = &out_buf };
        try self.renderTodoItem(&writer, row);
        return zs.Response.init(.ok, writer.buffer[0..writer.pos], "text/html; charset=utf-8");
    }

    pub fn addHandler(self: *const TodoApp, ctx: *zs.Context(TodoApp)) !zs.Response {
        var title_buf: [1024]u8 = undefined;
        const title_opt = try zs.form.getUrlEncodedValue(ctx.request.body, "title", &title_buf);
        const title = title_opt orelse {
            return zs.Response.init(.bad_request, "Missing title", "text/plain; charset=utf-8");
        };
        const Params = struct { title: sl.Text };
        const params = Params{ .title = .{ .data = title } };
        try self.db.exec("INSERT INTO todos (title) VALUES (:title)", params);
        var out_buf: [4096]u8 = undefined;
        var writer = zh.FixedWriter{ .buffer = &out_buf };
        try self.renderList(&writer);
        return zs.Response.init(.ok, writer.buffer[0..writer.pos], "text/html; charset=utf-8");
    }

    pub fn deleteHandler(self: *const TodoApp, ctx: *zs.Context(TodoApp)) !zs.Response {
        const id_str = ctx.request.query.get("id") orelse {
            return zs.Response.init(.bad_request, "Missing id", "text/plain");
        };
        const id = std.fmt.parseInt(i64, id_str, 10) catch {
            return zs.Response.init(.bad_request, "Invalid id", "text/plain");
        };
        const Params = struct { id: i64 };
        try self.db.exec("DELETE FROM todos WHERE id = :id", Params{ .id = id });
        return zs.Response.init(.ok, "", "text/html");
    }

    pub fn renderRoot(self: *const TodoApp, writer: *zh.FixedWriter) !void {
        writer.write("<!doctype html>");
        const html = zh.element(writer, "html", .{});
        defer html.close();
        {
            const head = zh.element(writer, "head", .{});
            defer head.close();
            const script = zh.element(writer, "script", .{ .src = "https://unpkg.com/htmx.org@2.0.2" });
            defer script.close();
        }
        const body = zh.element(writer, "body", .{});
        defer body.close();
        try self.renderList(writer);
        self.renderAdd(writer);
    }

    pub fn rootHandler(self: *const TodoApp, ctx: *zs.Context(TodoApp)) !zs.Response {
        _ = ctx;
        var buf: [65536]u8 = undefined;
        var writer = zh.FixedWriter{ .buffer = &buf };
        try self.renderRoot(&writer);
        return zs.Response.init(.ok, buf[0..writer.pos], "text/html");
    }
};

const Handler = enum {
    root,
    add,
    delete,
    toggle,
};

const Dispatch = struct {
    pub const HandlerId = Handler;
    pub fn dispatch(id: HandlerId, ctx: *zs.Context(TodoApp)) ?zs.Response {
        return switch (id) {
            .root => ctx.env.rootHandler(ctx) catch |err| {
                std.log.err("root error: {}\n", .{err});
                return zs.Response.init(.internal_server_error, "Internal Error", "text/html");
            },
            .add => ctx.env.addHandler(ctx) catch |err| {
                std.log.err("add error: {}\n", .{err});
                return zs.Response.init(.internal_server_error, "Internal Error", "text/html");
            },
            .delete => ctx.env.deleteHandler(ctx) catch |err| {
                std.log.err("delete error: {}\n", .{err});
                return zs.Response.init(.internal_server_error, "Internal Error", "text/html");
            },
            .toggle => ctx.env.toggleHandler(ctx) catch |err| {
                std.log.err("toggle error: {}\n", .{err});
                return zs.Response.init(.internal_server_error, "Internal Error", "text/html");
            },
        };
    }
};

const routes = [_]zs.Route(Handler){
    .{ .method = .GET, .path = "/", .handler = .root },
    .{ .method = .POST, .path = "/add", .handler = .add },
    .{ .method = .DELETE, .path = "/delete", .handler = .delete },
    .{ .method = .POST, .path = "/toggle/{id}", .handler = .toggle },
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);
    var port: u16 = 3030;
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--port")) {
            if (i + 1 < args.len) {
                port = try std.fmt.parseInt(u16, args[i + 1], 10);
                i += 1;
            } else {
                std.debug.print("error: --port requires a value\n", .{});
                return error.InvalidArgs;
            }
        }
    }
    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();
    var db = try sl.Database.open(.{ .path = "todos.db" });
    defer db.close();
    try db.exec("CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, completed INTEGER NOT NULL DEFAULT 0)", .{});
    const app = TodoApp{ .db = &db };
    const ServerType = zs.Server(Dispatch, TodoApp, &routes);
    var server = ServerType.init(app);
    server.setHost("0.0.0.0");
    server.setPort(port);
    try server.start(io);
}
