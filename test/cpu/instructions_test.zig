const std = @import("std");
const assert = std.debug.assert;
const instructions = @import("../../src/cpu/op_codes.zig");
const Emulated6502 = @import("../../src/cpu/cpu.zig").Emulated6502;
const Bus = @import("../../src/Bus.zig").Bus;

test "ORA ind,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x05,
        .x = 0x02,
    };

    memory[0x0] = 0x01; // ORA ind,x
    memory[0x1] = 0x03; // operand, 0x3 + 0x2 = 0x5

    memory[0x5] = 0xAA; // ptr lo
    memory[0x6] = 0xFF; // ptr hi

    memory[0xFFAA] = 0x20;

    cpu.clock();
    cpu.log();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 5);
    assert(cpu.pc == 0x02);
    assert(cpu.x == 0x02);
}

test "ORA zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
        .x = 0x02,
    };

    memory[0x0] = 0x05; // ORA zpg
    memory[0x1] = 0x03;
    memory[0x3] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 2);
    assert(cpu.pc == 0x02);
    assert(cpu.x == 0x02);
}

test "AND # operation: 0x05 and 0x10 = " {
    // var memory = [_]u8{0} ** (64 * 1024);
    // var cpu = Emulated6502{
    //     .bus = &Bus.init(&memory),
    //     .pc = 0x0,
    //     .ac = 0b00001111,
    // };
    // memory[0x0] = 0x29; // add implied instruction
    // memory[0x1] = 0b01010101; // operand

    // cpu.runOperation();

    // assert(true);
    // // todo assert(cpu.ac == 0x00000101);
}
