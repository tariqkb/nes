const std = @import("std");
const assert = std.debug.assert;
const Bus = @import("../../src/Bus.zig").Bus;
const cpu = @import("../../src/cpu/cpu.zig");

test "reset() resets all registers" {
    var memory = [_]u8{0} ** (64 * 1024);
    var emu_cpu = cpu.Emulated6502{
        .bus = &Bus.init(&memory),
        .ac = 1,
        .x = 1,
        .y = 1,
        .status = 1,
        .stkp = 1,
        .pc = 1,

        .operand = 1,
    };
    emu_cpu.reset();

    assert(emu_cpu.ac == 0);
    assert(emu_cpu.x == 0);
    assert(emu_cpu.y == 0);
    assert(emu_cpu.status == 0);
    assert(emu_cpu.stkp == 0);
    assert(emu_cpu.pc == 0);

    assert(emu_cpu.operand == 0);
}

test "setStatus() sets the status register" {
    var memory = [_]u8{0} ** (64 * 1024);
    var emu_cpu = cpu.Emulated6502{
        .bus = &Bus.init(&memory),
        .status = @enumToInt(cpu.StatusRegister.C),
    };
    emu_cpu.setStatus(cpu.StatusRegister.D);
    assert(emu_cpu.status == 1 << 3);
}

test "write() writes memory to address" {
    var memory = [_]u8{0} ** (64 * 1024);
    var emu_cpu = cpu.Emulated6502{
        .bus = &Bus.init(&memory),
    };
    memory[0xAA] = 0xFF;

    emu_cpu.write(0xAA, 0xBB);

    assert(memory[0xBB] == 0);
    assert(memory[0xAA] == 0xBB);
}

test "read() reads memory by address" {
    var memory = [_]u8{0} ** (64 * 1024);
    var emu_cpu = cpu.Emulated6502{ .bus = &Bus.init(&memory) };
    memory[0xAA] = 0xBD;

    assert(emu_cpu.bus.read(0xAA) == 0xBD);
}
