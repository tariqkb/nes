const std = @import("std");
const warn = std.debug.warn;
const as = @import("builtin").as;
const assert = std.debug.assert;

test "playground" {
    const a: u8 = 15;
    const b: u8 = 6; // -10

    const c = a +% (b | 0xF0);

    warn("\nc: {}\n", .{c});
    assert(c == 5);
}
