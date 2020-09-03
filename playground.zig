const std = @import("std");
const warn = std.debug.warn;
const as = @import("builtin").as;
const assert = std.debug.assert;

test "playground" {
    const b: u8 = 0x10;
    const a: u8 = 0x20;
    const c = b -% a;
    warn("\nc: {}\n", .{c});
    warn("\nc & 0x80: {}\n", .{c & 0x80});
}
