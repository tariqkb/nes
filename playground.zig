const std = @import("std");
const warn = std.debug.warn;
const as = @import("builtin").as;
const assert = std.debug.assert;

test "playground" {
    var b: u8 = undefined;
    const a: u8 = 0b00111111;
    const c = @shlWithOverflow(u8, a, 1, &b);
    warn("\nc: {} b: {} \n", .{ c, b });
}
