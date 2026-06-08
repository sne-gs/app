const std = @import("std");

pub const MAX_HTML_SIZE = 65536;

pub const FixedWriter = struct {
    buffer: []u8,
    pos: usize = 0,

    pub fn write(self: *FixedWriter, bytes: []const u8) void {
        std.debug.assert(self.pos + bytes.len <= self.buffer.len);
        @memcpy(self.buffer[self.pos..][0..bytes.len], bytes);
        self.pos += bytes.len;
    }

    pub fn writeChar(self: *FixedWriter, ch: u8) void {
        self.write(&[_]u8{ch});
    }

    pub fn writeEscaped(self: *FixedWriter, value: []const u8) void {
        for (value) |c| {
            switch (c) {
                '&' => self.write("&amp;"),
                '<' => self.write("&lt;"),
                '>' => self.write("&gt;"),
                '"' => self.write("&quot;"),
                else => self.writeChar(c),
            }
        }
    }
};

fn writeAttribute(writer: *FixedWriter, comptime name: []const u8, value: []const u8) void {
    comptime var attr_name: [name.len]u8 = undefined;
    inline for (name, 0..) |c, i| {
        attr_name[i] = if (c == '_') '-' else c;
    }
    writer.write(" " ++ &attr_name ++ "=\"");
    writer.writeEscaped(value);
    writer.writeChar('"');
}

pub fn TagGuard(comptime tag: []const u8) type {
    return struct {
        writer: *FixedWriter,
        pub fn close(self: @This()) void {
            self.writer.write("</" ++ tag ++ ">");
        }
    };
}

pub fn element(writer: *FixedWriter, comptime tag: []const u8, attributes: anytype) TagGuard(tag) {
    writer.write("<" ++ tag);
    const fields = @typeInfo(@TypeOf(attributes)).@"struct".fields;
    inline for (fields) |field| {
        const val = @field(attributes, field.name);
        if (@typeInfo(field.type) == .optional) {
            if (val) |actual_value| {
                writeAttribute(writer, field.name, actual_value);
            }
        } else {
            writeAttribute(writer, field.name, val);
        }
    }
    writer.writeChar('>');
    return .{ .writer = writer };
}

pub fn text(writer: *FixedWriter, content: []const u8) void {
    writer.writeEscaped(content);
}
