const std = @import("std");
const assert = std.debug.assert;
const Bus = @import("../../src/Bus.zig").Bus;
const Emulated6502 = @import("../../src/cpu/cpu.zig").Emulated6502;
const StatusFlag = @import("../../src/cpu/cpu.zig").StatusFlag;

test "reset() resets all registers" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .ac = 1,
        .x = 1,
        .y = 1,
        .status = 1,
        .stkp = 1,
        .pc = 1,

        .operand = 1,
    };
    cpu.reset();

    assert(cpu.ac == 0);
    assert(cpu.x == 0);
    assert(cpu.y == 0);
    assert(cpu.status == 0 | @enumToInt(StatusFlag.U));
    assert(cpu.stkp == 0xFF);
    assert(cpu.pc == 0);

    assert(cpu.operand == 0);
}

test "getFlag() gets the correct value from the status register" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .status = 0b00011111,
    };

    assert(cpu.getFlag(StatusFlag.D) == true);
    assert(cpu.getFlag(StatusFlag.N) == false);
}

test "setFlag() sets the status register" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .status = 0,
    };
    cpu.setFlag(StatusFlag.D, true);
    assert(cpu.status == 1 << 3);
}

test "setFlag() unsets the status register" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .status = 0b00001000,
    };
    cpu.setFlag(StatusFlag.D, false);
    assert(cpu.status == 0);
}

test "write() writes memory to address" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
    };
    memory[0xAA] = 0xFF;

    cpu.write(0xAA, 0xBB);

    assert(memory[0xBB] == 0);
    assert(memory[0xAA] == 0xBB);
}

test "read() reads memory by address" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{ .bus = &Bus.init(&memory) };
    memory[0xAA] = 0xBD;

    assert(cpu.bus.read(0xAA) == 0xBD);
}
