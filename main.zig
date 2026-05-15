const std = @import("std");
const zs = @import("zs");

const index_html = @embedFile("static/index.html");
const output_css = @embedFile("static/output.css");
const fixi_js = @embedFile("static/fixi.js");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var threaded = std.Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var server = try zs.Server.init(allocator);
    server.setHost("0.0.0.0");
    server.setPort(3000);
    server.setIndex("static/index.html");

    try server.addRoute(.GET, "/app", .{
        .handler = struct {
            fn handle(req: zs.Request) zs.Response {
                _ = req;
                return zs.Response.init(.ok, index_html, "text/html");
            }
        }.handle,
    });

    try server.addRoute(.GET, "/style.css", .{
        .handler = struct {
            fn handle(req: zs.Request) zs.Response {
                _ = req;
                return zs.Response.init(.ok, output_css, "text/css");
            }
        }.handle,
    });

    try server.addRoute(.GET, "/fixi.js", .{
        .handler = struct {
            fn handle(req: zs.Request) zs.Response {
                _ = req;
                return zs.Response.init(.ok, fixi_js, "application/javascript");
            }
        }.handle,
    });

    try server.addRoute(.GET, "/hello", .{
        .handler = struct {
            fn handle(req: zs.Request) zs.Response {
                _ = req;
                return zs.Response.init(.ok, "<p class=\"text-lg text-success\">Hello from fixi!</p>", "text/html");
            }
        }.handle,
    });

    try server.addRoute(.POST, "/clicked", .{
        .handler = struct {
            fn handle(req: zs.Request) zs.Response {
                _ = req;
                return zs.Response.init(.ok, "<div class=\"alert alert-success\">Button was clicked!</div>", "text/html");
            }
        }.handle,
    });

    try server.addRoute(.GET, "/content", .{
        .handler = struct {
            fn handle(req: zs.Request) zs.Response {
                _ = req;
                return zs.Response.init(.ok, "<p class=\"text-lg\">New content loaded via fixi</p>", "text/html");
            }
        }.handle,
    });

    try server.start(io);
}
