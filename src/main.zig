const std = @import("std");
const cpu = @import("./cpu/Cpu.zig");
const Bus = @import("./bus.zig").Bus;

pub fn main() anyerror!void {
    std.debug.warn("All your base are belong to us.\n", .{});

    var bus = Bus{
        .memory = undefined,
    };

    const cpu = cpu.Emulated6502{
        .bus = bus,
    };
}
