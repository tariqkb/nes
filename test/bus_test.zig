const std = @import("std");
const assert = std.debug.assert;
const Bus = @import("../src/Bus.zig").Bus;

test "bus reads memory by address" {
    var memory = [_]u8{0} ** (64 * 1024);
    var bus = Bus.init(&memory);
    bus.memory[0xAA] = 0xFF;

    assert(bus.read(0xAA) == 0xFF);
}

test "bus writes memory to address" {
    var memory = [_]u8{0} ** (64 * 1024);
    var bus = Bus.init(&memory);
    bus.memory[0xAA] = 0xFF;

    bus.write(0xAA, 0xBB);

    assert(bus.memory[0xAA] == 0xBB);
}
