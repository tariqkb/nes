const std = @import("std");
const Emulated6502 = @import("./cpu/Cpu.zig").Emulated6502;
const Bus = @import("./Bus.zig").Bus;

pub fn main() anyerror!void {
    std.debug.warn("All your base are belong to us.\n", .{});

    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
    };
}
