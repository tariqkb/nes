const std = @import("std");
const assert = std.debug.assert;
const instructions = @import("../../src/cpu/instructions.zig");
const cpu = @import("../../src/cpu/cpu.zig");
const Bus = @import("../../src/Bus.zig").Bus;

test "AND # operation: 0x05 and 0x10 = " {
    var memory = [_]u8{0} ** (64 * 1024);
    var emu_cpu = cpu.Emulated6502{
        .bus = &Bus.init(&memory),
    };
    emu_cpu.pc = 0x0;
    memory[0x0] = 0x29; // add implied instruction
    memory[0x1] = 0x01010101; // operand

    emu_cpu.ac = 0b00001111;

    emu_cpu.runOperation();

    // assert(true);
    assert(emu_cpu.ac == 0x00000101);
}
