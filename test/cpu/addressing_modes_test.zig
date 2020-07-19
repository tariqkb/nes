const std = @import("std");
const assert = std.debug.assert;
const Emulated6502 = @import("../../src/cpu/cpu.zig").Emulated6502;
const Bus = @import("../../src/Bus.zig").Bus;
const addressing_modes = @import("../../src/cpu/addressing_modes.zig");

test "acc" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .ac = 0x03,
    };

    const extra_cycle = addressing_modes.acc(&cpu);

    assert(cpu.operand_addr == 0);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x0);
    assert(extra_cycle == 0);
}

test "impl" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .operand = 0x01,
        .operand_addr = 0x01,
    };

    const extra_cycle = addressing_modes.impl(&cpu);

    assert(cpu.operand_addr == 0);
    assert(cpu.operand == 0);
    assert(cpu.pc == 0x0);
    assert(extra_cycle == 0);
}

test "imm" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
    };
    memory[0x01] = 0x03;

    const extra_cycle = addressing_modes.imm(&cpu);

    assert(cpu.operand_addr == 0);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
    };
    memory[0x01] = 0x05;
    memory[0x05] = 0x03;

    const extra_cycle = addressing_modes.zpg(&cpu);

    assert(cpu.operand_addr == 0x0005);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "zpg, X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .x = 0x04,
    };
    memory[0x01] = 0x02;
    memory[0x06] = 0x03;

    const extra_cycle = addressing_modes.zpgX(&cpu);

    assert(cpu.operand_addr == 0x0006);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "zpg, X: overflow" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .x = 0x04,
    };
    memory[0x01] = 0xFF;
    memory[0x03] = 0x03;

    const extra_cycle = addressing_modes.zpgX(&cpu);

    assert(cpu.operand_addr == 0x0003);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "zpg, Y" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .y = 0x04,
    };
    memory[0x01] = 0x02;
    memory[0x06] = 0x03;

    const extra_cycle = addressing_modes.zpgY(&cpu);

    assert(cpu.operand_addr == 0x0006);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "zpg, Y: overflow" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .y = 0x04,
    };
    memory[0x01] = 0xFF;
    memory[0x03] = 0x03;

    const extra_cycle = addressing_modes.zpgY(&cpu);

    assert(cpu.operand_addr == 0x0003);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
    };
    memory[0x01] = 0x20;
    memory[0x02] = 0x30;
    memory[0x3020] = 0x03;

    const extra_cycle = addressing_modes.abs(&cpu);

    assert(cpu.operand_addr == 0x3020);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x03);
    assert(extra_cycle == 0);
}

test "abs,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .x = 0x05,
    };
    memory[0x01] = 0x20;
    memory[0x02] = 0x30;
    memory[0x3025] = 0x03;

    const extra_cycle = addressing_modes.absX(&cpu);

    assert(cpu.operand_addr == 0x3025);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x03);
    assert(extra_cycle == 0);
}

test "abs,X: cross page" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .x = 0x05,
    };
    memory[0x01] = 0xFF;
    memory[0x02] = 0x01;
    memory[0x0204] = 0x03;

    const extra_cycle = addressing_modes.absX(&cpu);

    assert(cpu.operand_addr == 0x0204);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x03);
    assert(extra_cycle == 1);
}

test "abs,Y" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .y = 0x05,
    };
    memory[0x01] = 0x20;
    memory[0x02] = 0x30;
    memory[0x3025] = 0x03;

    const extra_cycle = addressing_modes.absY(&cpu);

    assert(cpu.operand_addr == 0x3025);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x03);
    assert(extra_cycle == 0);
}

test "abs,Y: cross page" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .y = 0x05,
    };
    memory[0x01] = 0xFF;
    memory[0x02] = 0x01;
    memory[0x0204] = 0x03;

    const extra_cycle = addressing_modes.absY(&cpu);

    assert(cpu.operand_addr == 0x0204);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x03);
    assert(extra_cycle == 1);
}

test "ind" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
    };
    memory[0x01] = 0x10;
    memory[0x02] = 0x20;
    memory[0x2010] = 0x20;
    memory[0x2011] = 0x30;
    memory[0x3020] = 0x03;

    const extra_cycle = addressing_modes.ind(&cpu);

    assert(cpu.operand_addr == 0x3020);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x03);
    assert(extra_cycle == 0);
}

test "ind: page boundary bug" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
    };
    memory[0x01] = 0xFF;
    memory[0x02] = 0x11;
    memory[0x1100] = 0x30;
    memory[0x11FF] = 0x20;
    memory[0x1200] = 0x40;
    memory[0x3020] = 0x03;

    const extra_cycle = addressing_modes.ind(&cpu);

    assert(cpu.operand_addr == 0x3020);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x03);
    assert(extra_cycle == 0);
}

test "ind,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .x = 0x05,
    };
    memory[0x01] = 0x10;
    memory[0x0015] = 0x20;
    memory[0x0016] = 0x30;
    memory[0x3020] = 0x03;

    const extra_cycle = addressing_modes.indX(&cpu);

    assert(cpu.operand_addr == 0x3020);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "ind,X: overflow" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .x = 0x05,
    };
    memory[0x0001] = 0xFF;
    memory[0x0004] = 0x20;
    memory[0x0005] = 0x30;
    memory[0x3020] = 0x03;

    const extra_cycle = addressing_modes.indX(&cpu);

    assert(cpu.operand_addr == 0x3020);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "ind,Y" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .y = 0x05,
    };
    memory[0x01] = 0x10;
    memory[0x0010] = 0x1B;
    memory[0x0011] = 0x30;
    memory[0x3020] = 0x03;

    const extra_cycle = addressing_modes.indY(&cpu);

    assert(cpu.operand_addr == 0x3020);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 0);
}

test "ind,Y: cross page boundary" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x01,
        .y = 0x05,
    };
    memory[0x01] = 0x10;
    memory[0x0010] = 0xFF;
    memory[0x0011] = 0x01;
    memory[0x0204] = 0x03;

    const extra_cycle = addressing_modes.indY(&cpu);

    assert(cpu.operand_addr == 0x0204);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x02);
    assert(extra_cycle == 1);
}

test "rel: positive offset" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x20,
    };
    memory[0x20] = 0x10;
    memory[0x30] = 0x03;

    const extra_cycle = addressing_modes.rel(&cpu);

    assert(cpu.operand_addr == 0x30);
    assert(cpu.operand == 0x03);
    assert(extra_cycle == 0);
}

test "rel: negative offset" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x20,
    };
    memory[0x20] = 0xF0;
    memory[0x10] = 0x03;

    const extra_cycle = addressing_modes.rel(&cpu);

    assert(cpu.operand_addr == 0x10);
    assert(cpu.operand == 0x03);
    assert(cpu.pc == 0x21);
    assert(extra_cycle == 0);
}
