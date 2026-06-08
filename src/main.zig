const std = @import("std");
const zs = @import("zs");
const zui = @import("zui.zig");

pub const Action = enum {
    click,
    about_click,
};

fn buttonComponent(writer: *zui.FixedWriter, label: []const u8, action: Action) void {
    var action_path_buf: [64]u8 = undefined;
    const action_path = std.fmt.bufPrint(&action_path_buf, "/_action/{s}", .{@tagName(action)}) catch "/_action/unknown";
    const btn = zui.element(writer, "button", .{
        .hx_post = action_path,
        .hx_swap = "outerHTML",
    });
    defer btn.close();
    zui.text(writer, label);
}

fn appContent(writer: *zui.FixedWriter) void {
    {
        const div = zui.element(writer, "div", .{ .class = "container" });
        defer div.close();
        {
            const span = zui.element(writer, "span", .{});
            defer span.close();
            buttonComponent(writer, "Hello!", .click);
        }
    }
}

fn renderPage(writer: *zui.FixedWriter) void {
    writer.write("<!doctype html>");
    {
        const html = zui.element(writer, "html", .{});
        defer html.close();
        {
            const head = zui.element(writer, "head", .{});
            defer head.close();
            const script = zui.element(writer, "script", .{ .src = "https://unpkg.com/htmx.org@2.0.2" });
            defer script.close();
        }
        {
            const body = zui.element(writer, "body", .{});
            defer body.close();
            appContent(writer);
        }
    }
}

fn handleClick(writer: *zui.FixedWriter, allocator: std.mem.Allocator) void {
    _ = allocator;
    {
        const div = zui.element(writer, "div", .{ .class = "alert" });
        defer div.close();
        zui.text(writer, "Clicked!");
    }
}

fn handleAboutClick(writer: *zui.FixedWriter, allocator: std.mem.Allocator) void {
    _ = allocator;
    {
        const div = zui.element(writer, "div", .{ .class = "info" });
        defer div.close();
        zui.text(writer, "About page clicked");
    }
}

const baked = struct {
    pub const app_page: []const u8 = b: {
        var buf: [65536]u8 = undefined;
        var writer = zui.FixedWriter{ .buffer = &buf };
        renderPage(&writer);
        const final_html = buf[0..writer.pos].*;
        break :b &final_html;
    };

    pub const click_fragment: []const u8 = b: {
        var buf: [4096]u8 = undefined;
        var writer = zui.FixedWriter{ .buffer = &buf };
        handleClick(&writer, undefined);

        const final_html = buf[0..writer.pos].*;
        break :b &final_html;
    };

    pub const about_fragment: []const u8 = b: {
        var buf: [4096]u8 = undefined;
        var writer = zui.FixedWriter{ .buffer = &buf };
        handleAboutClick(&writer, undefined);

        const final_html = buf[0..writer.pos].*;
        break :b &final_html;
    };
};

fn rootHandler(ctx: *zs.Context) zs.Response {
    _ = ctx;
    return zs.Response.init(.ok, baked.app_page, "text/html");
}

fn actionHandler(ctx: *zs.Context) zs.Response {
    const action_name = ctx.request.params.get("action") orelse {
        return zs.Response.init(.bad_request, "missing action", "text/plain");
    };

    const action = std.meta.stringToEnum(Action, action_name) orelse {
        return zs.Response.init(.not_found, "unknown action", "text/plain");
    };

    const html = switch (action) {
        .click => baked.click_fragment,
        .about_click => baked.about_fragment,
    };

    return zs.Response.init(.ok, html, "text/html");
}

const MyHandler = enum {
    hello,
    root,
    action,
};

fn helloHandler(ctx: *zs.Context) zs.Response {
    _ = ctx;
    return zs.Response.init(.ok, "Hello, World!", "text/html");
}

const MyDispatch = struct {
    pub const HandlerId = MyHandler;

    pub fn dispatch(id: HandlerId, ctx: *zs.Context) ?zs.Response {
        return switch (id) {
            .hello => helloHandler(ctx),
            .root => rootHandler(ctx),
            .action => actionHandler(ctx),
        };
    }
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);

    var port: u16 = 3000;
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

    const ServerType = zs.Server(MyDispatch);
    var server = try ServerType.init(allocator);
    server.setHost("0.0.0.0");
    server.setPort(port);
    server.mapStaticAssets("ui/public");

    try server.addRoute(.GET, "/hello", .hello);
    try server.addRoute(.GET, "/app", MyHandler.root);
    try server.addRoute(.POST, "/_action/{action}", MyHandler.action);

    try server.start(io);
}
