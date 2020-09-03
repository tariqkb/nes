const std = @import("std");
const assert = std.debug.assert;
const op_codes = @import("../../src/cpu/op_codes.zig");
const Emulated6502 = @import("../../src/cpu/cpu.zig").Emulated6502;
const StatusFlag = @import("../../src/cpu/cpu.zig").StatusFlag;
const Bus = @import("../../src/Bus.zig").Bus;

test "BRK impl" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x1020,
        .status = 0b00000000,
        .stkp = 0xFF,
    };

    memory[0x1020] = 0x00;
    memory[0xFFFE] = 0x20;
    memory[0xFFFF] = 0x30;

    cpu.clock();

    assert(cpu.pc == 0x3020);
    assert(cpu.status == 0b00000000);
    assert(memory[0x01FD] == 0b00010000);
    assert(memory[0x01FE] == 0x21);
    assert(memory[0x01FF] == 0x10);
    assert(cpu.stkp == 0xFC);
    assert(cpu.cycles == 6);
}

test "ORA ind,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x05,
        .x = 0x02,
    };

    memory[0x0] = 0x01;
    memory[0x1] = 0x03;

    memory[0x5] = 0xAA;
    memory[0x6] = 0xFF;

    memory[0xFFAA] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 5);
    assert(cpu.pc == 0x02);
    assert(cpu.x == 0x02);
    assert(cpu.getFlag(StatusFlag.Z) == false);
    assert(cpu.getFlag(StatusFlag.N) == false);
}

test "ORA ind,X: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x0,
        .x = 0x02,
    };

    memory[0x0] = 0x01;
    memory[0x1] = 0x03;

    memory[0x5] = 0xAA;
    memory[0x6] = 0xFF;

    memory[0xFFAA] = 0x0;

    cpu.clock();

    assert(cpu.ac == 0x0);
    assert(cpu.cycles == 5);
    assert(cpu.pc == 0x02);
    assert(cpu.x == 0x02);
    assert(cpu.getFlag(StatusFlag.Z) == true);
    assert(cpu.getFlag(StatusFlag.N) == false);
}

test "ORA ind,X: negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0xFF,
        .x = 0x02,
    };

    memory[0x0] = 0x01;
    memory[0x1] = 0x03;

    memory[0x5] = 0xAA;
    memory[0x6] = 0xFF;

    memory[0xFFAA] = 0x1;

    cpu.clock();

    assert(cpu.ac == 0xFF);
    assert(cpu.cycles == 5);
    assert(cpu.pc == 0x02);
    assert(cpu.x == 0x02);
    assert(cpu.getFlag(StatusFlag.Z) == false);
    assert(cpu.getFlag(StatusFlag.N) == true);
}

test "ORA ind,Y" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x05,
        .y = 0x02,
    };

    memory[0x0] = 0x11;
    memory[0x1] = 0x03;

    memory[0x3] = 0xAA;
    memory[0x4] = 0xFF;

    memory[0xFFAC] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 4);
    assert(cpu.pc == 0x02);
    assert(cpu.y == 0x02);
    assert(cpu.getFlag(StatusFlag.Z) == false);
    assert(cpu.getFlag(StatusFlag.N) == false);
}

test "ORA zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
        .x = 0x02,
    };

    memory[0x0] = 0x05;
    memory[0x1] = 0x03;
    memory[0x3] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 2);
    assert(cpu.pc == 0x02);
    assert(cpu.x == 0x02);
}

test "ORA zpg,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
        .x = 0x02,
    };

    memory[0x0] = 0x15;
    memory[0x1] = 0x03;
    memory[0x5] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 3);
    assert(cpu.pc == 0x02);
    assert(cpu.x == 0x02);
}

test "ORA #" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
    };

    memory[0x0] = 0x09;
    memory[0x1] = 0x03;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x03);
    assert(cpu.cycles == 1);
    assert(cpu.pc == 0x02);
}

test "ORA abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
    };

    memory[0x0] = 0x0D;
    memory[0x1] = 0x03;
    memory[0x2] = 0x20;
    memory[0x2003] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 3);
    assert(cpu.pc == 0x03);
}

test "ORA abs,Y" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
        .y = 0x5,
    };

    memory[0x0] = 0x19;
    memory[0x1] = 0x03;
    memory[0x2] = 0x20;
    memory[0x2008] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 3);
    assert(cpu.pc == 0x03);
}

test "ORA abs,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
        .x = 0x05,
    };

    memory[0x0] = 0x1D;
    memory[0x1] = 0x03;
    memory[0x2] = 0x20;
    memory[0x2008] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05 | 0x20);
    assert(cpu.cycles == 3);
    assert(cpu.pc == 0x03);
}

test "ASL zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b11111111,
    };

    memory[0x0] = 0x06;
    memory[0x1] = 0x03;
    memory[0x3] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x0);
    assert(cpu.cycles == 4);
    assert(cpu.pc == 0x02);
    assert(memory[0x03] == 0x40);
    assert(cpu.getFlag(StatusFlag.Z) == false);
    assert(cpu.getFlag(StatusFlag.C) == false);
    assert(cpu.getFlag(StatusFlag.N) == false);
}

test "ASL zpg: carry flag, zero flag" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0,
    };

    memory[0x0] = 0x06;
    memory[0x1] = 0x03;
    memory[0x3] = 0b10000000;

    cpu.clock();

    assert(cpu.ac == 0x0);
    assert(cpu.cycles == 4);
    assert(cpu.pc == 0x02);
    assert(memory[0x03] == 0x0);
    assert(cpu.getFlag(StatusFlag.Z) == true);
    assert(cpu.getFlag(StatusFlag.C) == true);
    assert(cpu.getFlag(StatusFlag.N) == false);
}

test "ASL zpg: negative flag" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0,
    };

    memory[0x0] = 0x06;
    memory[0x1] = 0x03;
    memory[0x3] = 0b01000000;

    cpu.clock();

    assert(cpu.ac == 0x0);
    assert(cpu.cycles == 4);
    assert(cpu.pc == 0x02);
    assert(memory[0x03] == 0b10000000);
    assert(cpu.getFlag(StatusFlag.Z) == false);
    assert(cpu.getFlag(StatusFlag.C) == false);
    assert(cpu.getFlag(StatusFlag.N) == true);
}

test "ASL zpg,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .x = 0x2,
        .status = 0b11111111,
    };

    memory[0x0] = 0x16;
    memory[0x1] = 0x03;
    memory[0x5] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x0);
    assert(cpu.cycles == 5);
    assert(cpu.pc == 0x02);
    assert(memory[0x05] == 0x40);
    assert(cpu.getFlag(StatusFlag.Z) == false);
    assert(cpu.getFlag(StatusFlag.C) == false);
    assert(cpu.getFlag(StatusFlag.N) == false);
}

test "ASL A" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x20,
        .status = 0b11111111,
    };

    memory[0x0] = 0x0A;

    cpu.clock();

    assert(cpu.ac == 0x40);
    assert(cpu.cycles == 1);
    assert(cpu.pc == 0x01);
}

test "ASL abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
    };

    memory[0x0] = 0x0E;
    memory[0x1] = 0x03;
    memory[0x2] = 0x20;
    memory[0x2003] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05);
    assert(memory[0x2003] == 0x20 << 1);
    assert(cpu.cycles == 5);
    assert(cpu.pc == 0x03);
}

test "ASL abs,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x05,
        .x = 0x05,
    };

    memory[0x0] = 0x1E;
    memory[0x1] = 0x03;
    memory[0x2] = 0x20;
    memory[0x2008] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x05);
    assert(memory[0x2008] == 0x20 << 1);
    assert(cpu.cycles == 6);
    assert(cpu.pc == 0x03);
}

test "PHP impl" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b11110000,
        .stkp = 0xFD,
    };

    memory[0x0] = 0x08;
    memory[0x01FD] = 0x20;

    cpu.clock();

    assert(cpu.cycles == 2);
    assert(cpu.pc == 0x01);
    assert(memory[0x01FD] == 0b11110000);
}

test "BPL rel" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0,
    };

    memory[0x0] = 0x10;
    memory[0x1] = 0x05;
    memory[0x7] = 0x03;

    cpu.clock();

    assert(cpu.pc == 0x07);
    assert(cpu.cycles == 2);
}

test "BPL rel: negative flag set" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = @enumToInt(StatusFlag.N),
    };

    memory[0x0] = 0x10;
    memory[0x1] = 0x05;
    memory[0x7] = 0x03;

    cpu.clock();

    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 1);
}

test "BPL rel: cross page boundary" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0xF8,
    };

    memory[0xF8] = 0x10;
    memory[0xF9] = 0x10;

    cpu.clock();

    assert(cpu.pc == 0x010A);
    assert(cpu.cycles == 3);
}

test "CLC" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = @enumToInt(StatusFlag.C),
    };

    memory[0x0] = 0x18;

    cpu.clock();

    assert(cpu.pc == 0x01);
    assert(cpu.getFlag(StatusFlag.C) == false);
    assert(cpu.cycles == 1);
}

test "JSR abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0100,
    };

    memory[0x0100] = 0x20;
    memory[0x0101] = 0x20;
    memory[0x0102] = 0x30;

    cpu.clock();

    assert(cpu.pc == 0x3020);
    assert(memory[0x01FE] == 0x02);
    assert(memory[0x01FF] == 0x01);
    assert(cpu.stkp == 0xFD);
    assert(cpu.cycles == 5);
}

test "AND ind,X" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .x = 0x5,
        .ac = 0x5,
        .status = 0b10000010,
    };

    memory[0x0] = 0x21;
    memory[0x1] = 0x10;
    memory[0x15] = 0x20;
    memory[0x16] = 0x30;
    memory[0x3020] = 0x3;

    cpu.clock();

    assert(cpu.pc == 0x2);
    assert(cpu.operand_addr == 0x3020);
    assert(cpu.operand == 0x3);
    assert(cpu.ac == 0x5 & 0x3);
    assert(cpu.status == 0b00000000);
    assert(cpu.cycles == 5);
}

test "BIT zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0,
    };

    memory[0x0] = 0x24;
    memory[0x1] = 0x20;
    memory[0x20] = 0b11000000;

    cpu.clock();

    assert(cpu.status == 0b11000010);
    assert(cpu.cycles == 2);
    assert(cpu.pc == 0x2);
}

test "BIT zpg: non-zero result, zero for bit 7 and 6" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 1,
    };

    memory[0x0] = 0x24;
    memory[0x1] = 0x20;
    memory[0x20] = 0b00000001;

    cpu.clock();

    assert(cpu.status == 0b00000000);
    assert(cpu.cycles == 2);
}

test "AND zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x5,
    };

    memory[0x0] = 0x25;
    memory[0x1] = 0x20;
    memory[0x0020] = 0x30;

    cpu.clock();

    assert(cpu.ac == 0x5 & 0x30);
    assert(cpu.operand_addr == 0x0020);
    assert(cpu.operand == 0x30);
    assert(cpu.status == 0b00000010);
    assert(cpu.cycles == 2);
}

test "ROL zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b00000000,
    };

    memory[0x0] = 0x26;
    memory[0x1] = 0x20;
    memory[0x0020] = 0b01000000;

    cpu.clock();

    assert(memory[0x0020] == 0b10000000);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "ROL zpg: overflow, existing carry" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b00000001,
    };

    memory[0x0] = 0x26;
    memory[0x1] = 0x20;
    memory[0x0020] = 0b10000000;

    cpu.clock();

    assert(memory[0x0020] == 0b00000001);
    assert(cpu.status == 0b00000001);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "ROL zpg: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b00000000,
    };

    memory[0x0] = 0x26;
    memory[0x1] = 0x20;
    memory[0x0020] = 0b10000000;

    cpu.clock();

    assert(memory[0x0020] == 0b00000000);
    assert(cpu.status == 0b00000011);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "PLP impl" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .stkp = 0x21,
        .status = 0b00000000,
    };

    memory[0x0] = 0x28;
    memory[0x0120] = 0b11111111;

    cpu.clock();

    assert(cpu.status == 0b11111111);
    assert(cpu.cycles == 3);
}

test "AND #" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x5,
    };

    memory[0x0] = 0x29;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x5 & 0x20);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "ROL A" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0b10000001,
    };

    memory[0x0] = 0x2A;

    cpu.clock();

    assert(cpu.ac == 0b00000010);
    assert(cpu.cycles == 1);
}

test "BIT abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0,
    };

    memory[0x0] = 0x2C;
    memory[0x1] = 0x20;
    memory[0x2] = 0x30;
    memory[0x3020] = 0b11000000;

    cpu.clock();

    assert(cpu.status == 0b11000010);
    assert(cpu.cycles == 3);
    assert(cpu.pc == 0x3);
}

test "AND abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x5,
    };

    memory[0x0] = 0x2D;
    memory[0x1] = 0x20;
    memory[0x2] = 0x30;
    memory[0x3020] = 0x20;

    cpu.clock();

    assert(cpu.ac == 0x5 & 0x20);
    assert(cpu.pc == 0x3);
    assert(cpu.cycles == 3);
}

test "ROL abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b10000001,
    };

    memory[0x0] = 0x2E;
    memory[0x1] = 0x20;
    memory[0x2] = 0x30;
    memory[0x3020] = 0b10000001;

    cpu.clock();

    assert(cpu.status == 0b00000001);
    assert(memory[0x3020] == 0b00000011);
    assert(cpu.pc == 0x3);
    assert(cpu.cycles == 5);
}

// TESTING OP CODE FUNCTIONS INSTEAD OF INTEGRATION BETWEEN OPCODE/ADDR MODE

test "BMI rel" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b10000000,
    };

    memory[0x0] = 0x30;
    memory[0x1] = 0x05;

    cpu.clock();

    assert(cpu.cycles == 2);
    assert(cpu.pc == 0x7);
}

test "BMI rel: no branch" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b00000000,
    };

    memory[0x0] = 0x30;
    memory[0x1] = 0x05;

    cpu.clock();

    assert(cpu.cycles == 1);
    assert(cpu.pc == 0x2);
}

test "SEC" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b10000000,
    };

    memory[0x0] = 0x38;

    cpu.clock();

    assert(cpu.status == 0b10000001);
    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 1);
}

test "RTI" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b00000000,
        .stkp = 0xFC,
    };

    memory[0x0] = 0x40;
    memory[0x01FF] = 0x30;
    memory[0x01FE] = 0x20;
    memory[0x01FD] = 0b10000001;

    cpu.clock();

    assert(cpu.status == 0b10000001);
    assert(cpu.pc == 0x3020);
    assert(cpu.cycles == 5);
}

test "JMP abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
    };

    memory[0x0] = 0x4C;
    memory[0x1] = 0x20;
    memory[0x2] = 0x30;

    cpu.clock();

    assert(cpu.pc == 0x3020);
    assert(cpu.cycles == 2);
}

test "EOR abs" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 5,
    };

    memory[0x0] = 0x4D;
    memory[0x1] = 0x20;
    memory[0x2] = 0x30;
    memory[0x3020] = 0x90;

    cpu.clock();

    assert(cpu.ac == 0x5 ^ 0x90);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x03);
    assert(cpu.cycles == 3);
}

test "LSR zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
    };

    memory[0x0] = 0x46;
    memory[0x1] = 0x20;
    memory[0x20] = 0b10000001;

    cpu.clock();

    assert(memory[0x20] == 0b01000000);
    assert(cpu.status == 0b00000001);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "LSR A" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0b00000000,
    };

    memory[0x0] = 0x4A;

    cpu.clock();

    assert(cpu.ac == 0b00000000);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 1);
}

test "PHA" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x5,
        .stkp = 0xFF,
    };

    memory[0x0] = 0x48;
    cpu.clock();

    assert(cpu.ac == 0x5);
    assert(memory[0x01FF] == 0x5);
    assert(cpu.stkp == 0xFE);
    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 2);
}

test "BVC rel" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0x50;
    memory[0x1] = 0x05;
    memory[0x7] = 0x03;

    cpu.clock();

    assert(cpu.pc == 0x07);
    assert(cpu.cycles == 2);
}

test "BVC rel: no branch" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b01000000,
    };

    memory[0x0] = 0x50;
    memory[0x1] = 0x05;

    cpu.clock();

    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 1);
}

test "CLI" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000100,
    };

    memory[0x0] = 0x58;

    cpu.clock();

    assert(cpu.status == 0b00000000);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "RTS" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .stkp = 0xFD,
    };

    memory[0x0] = 0x60;
    memory[0x01FF] = 0x30;
    memory[0x01FE] = 0x20;

    cpu.clock();

    assert(cpu.pc == 0x3021);
    assert(cpu.stkp == 0xFF);
    assert(cpu.cycles == 5);
}

test "ADC zp: overflow, carry" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0xA0,
        .status = 0b00000001,
    };

    memory[0x0] = 0x65;
    memory[0x1] = 0x20;
    memory[0x20] = 0xA0;

    cpu.clock();

    assert(cpu.pc == 0x2);
    assert(cpu.ac == 0x41);
    assert(cpu.status == 0b01000001);
    assert(cpu.cycles == 2);
}

test "ADC zp: no overflow, no carry" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0x20,
        .status = 0b11000010,
    };

    memory[0x0] = 0x65;
    memory[0x1] = 0x20;
    memory[0x20] = 0x20;

    cpu.clock();

    assert(cpu.pc == 0x2);
    assert(cpu.ac == 0x40);
    assert(cpu.status == 0b00000000);
    assert(cpu.cycles == 2);
}

test "PLA" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .stkp = 0xFE,
    };

    memory[0x0] = 0x68;
    memory[0x01FF] = 0x20;

    cpu.clock();

    assert(cpu.pc == 0x1);
    assert(cpu.ac == 0x20);
    assert(cpu.stkp == 0xFF);
    assert(cpu.cycles == 3);
}

test "ROR zpg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b00000000,
    };

    memory[0x0] = 0x66;
    memory[0x1] = 0x20;
    memory[0x0020] = 0b01000000;

    cpu.clock();

    assert(memory[0x0020] == 0b00100000);
    assert(cpu.status == 0b00000000);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "ROR zpg: overflow, existing carry" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b00000001,
    };

    memory[0x0] = 0x66;
    memory[0x1] = 0x20;
    memory[0x0020] = 0b00000001;

    cpu.clock();

    assert(memory[0x0020] == 0b10000000);
    assert(cpu.status == 0b10000001);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "ROR zpg: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .status = 0b00000000,
    };

    memory[0x0] = 0x66;
    memory[0x1] = 0x20;
    memory[0x0020] = 0b00000001;

    cpu.clock();

    assert(memory[0x0020] == 0b00000000);
    assert(cpu.status == 0b00000011);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "BVS rel" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b01000000,
    };

    memory[0x0] = 0x70;
    memory[0x1] = 0x05;
    memory[0x7] = 0x03;

    cpu.clock();

    assert(cpu.pc == 0x07);
    assert(cpu.cycles == 2);
}

test "BVS rel: no branch" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0x70;
    memory[0x1] = 0x05;

    cpu.clock();

    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 1);
}

test "SEI" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0x78;

    cpu.clock();

    assert(cpu.status == 0b00000100);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "STA zp" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x5,
    };

    memory[0x0] = 0x85;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(memory[0x20] == 0x5);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "STY zp" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0x5,
    };

    memory[0x0] = 0x84;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(memory[0x20] == 0x5);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "STX zp" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0x5,
    };

    memory[0x0] = 0x86;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(memory[0x20] == 0x5);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "DEY: negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0x81,
    };

    memory[0x0] = 0x88;

    cpu.clock();

    assert(cpu.status == 0b10000000);
    assert(cpu.y == 0x80);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "DEY: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0x1,
    };

    memory[0x0] = 0x88;

    cpu.clock();

    assert(cpu.status == 0b00000010);
    assert(cpu.y == 0);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "TXA" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0x80,
    };

    memory[0x0] = 0x8A;

    cpu.clock();

    assert(cpu.status == 0b10000000);
    assert(cpu.ac == 0x80);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "TXA: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x5,
        .x = 0x0,
    };

    memory[0x0] = 0x8A;

    cpu.clock();

    assert(cpu.status == 0b00000010);
    assert(cpu.ac == 0);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "BCC rel" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0x90;
    memory[0x1] = 0x05;
    memory[0x7] = 0x03;

    cpu.clock();

    assert(cpu.pc == 0x07);
    assert(cpu.cycles == 2);
}

test "BCC rel: no branch" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000001,
    };

    memory[0x0] = 0x90;
    memory[0x1] = 0x05;

    cpu.clock();

    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 1);
}

test "TYA" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0x80,
    };

    memory[0x0] = 0x98;

    cpu.clock();

    assert(cpu.status == 0b10000000);
    assert(cpu.ac == 0x80);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "TYA: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x5,
        .y = 0x0,
    };

    memory[0x0] = 0x98;

    cpu.clock();

    assert(cpu.status == 0b00000010);
    assert(cpu.ac == 0);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "TXS" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0xFA,
    };

    memory[0x0] = 0x9A;

    cpu.clock();

    assert(cpu.stkp == 0xFA);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "LDY zp" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
    };

    memory[0x0] = 0xA4;
    memory[0x01] = 0x20;
    memory[0x20] = 0x80;

    cpu.clock();

    assert(cpu.y == 0x80);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "LDY zp: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0x80,
    };

    memory[0x0] = 0xA4;
    memory[0x01] = 0x20;
    memory[0x20] = 0x0;

    cpu.clock();

    assert(cpu.y == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "LDX zp" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
    };

    memory[0x0] = 0xA6;
    memory[0x01] = 0x20;
    memory[0x20] = 0x80;

    cpu.clock();

    assert(cpu.x == 0x80);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "LDX zp: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0x80,
    };

    memory[0x0] = 0xA6;
    memory[0x01] = 0x20;
    memory[0x20] = 0x0;

    cpu.clock();

    assert(cpu.x == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "LDA zp" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
    };

    memory[0x0] = 0xA5;
    memory[0x01] = 0x20;
    memory[0x20] = 0x80;

    cpu.clock();

    assert(cpu.ac == 0x80);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "LDA zp: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x80,
    };

    memory[0x0] = 0xA5;
    memory[0x01] = 0x20;
    memory[0x20] = 0x0;

    cpu.clock();

    assert(cpu.ac == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 2);
}

test "TAY" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x80,
    };

    memory[0x0] = 0xA8;

    cpu.clock();

    assert(cpu.y == 0x80);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "TAY: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x0,
        .y = 0x5,
    };

    memory[0x0] = 0xA8;

    cpu.clock();

    assert(cpu.y == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "TAX" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x80,
    };

    memory[0x0] = 0xAA;

    cpu.clock();

    assert(cpu.x == 0x80);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "TAX: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x0,
        .x = 0x5,
    };

    memory[0x0] = 0xAA;

    cpu.clock();

    assert(cpu.x == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "BCS rel" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000001,
    };

    memory[0x0] = 0xB0;
    memory[0x1] = 0x05;
    memory[0x7] = 0x03;

    cpu.clock();

    assert(cpu.pc == 0x07);
    assert(cpu.cycles == 2);
}

test "BCS rel: no branch" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0xB0;
    memory[0x1] = 0x05;

    cpu.clock();

    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 1);
}

test "CLV" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b01000000,
    };

    memory[0x0] = 0xB8;

    cpu.clock();

    assert(cpu.status == 0b00000000);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "TSX" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .stkp = 0xFD,
    };

    memory[0x0] = 0xBA;

    cpu.clock();

    assert(cpu.x == 0xFD);
    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 1);
}

test "CPY imm: non-negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0x20,
    };

    memory[0x0] = 0xC0;
    memory[0x1] = 0x10;

    cpu.clock();

    assert(cpu.status == 0b00000001);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "CPY imm: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0x20,
    };

    memory[0x0] = 0xC0;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(cpu.status == 0b00000011);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "CPY imm: negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0x10,
        .status = 0b00000000,
    };

    memory[0x0] = 0xC0;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "CMP imm: non-negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x20,
    };

    memory[0x0] = 0xC9;
    memory[0x1] = 0x10;

    cpu.clock();

    assert(cpu.status == 0b00000001);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "CMP imm: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x20,
    };

    memory[0x0] = 0xC9;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(cpu.status == 0b00000011);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "CMP imm: negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .ac = 0x10,
        .status = 0b00000000,
    };

    memory[0x0] = 0xC9;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "DEC zp: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0xC6;
    memory[0x1] = 0x20;
    memory[0x20] = 0x1;

    cpu.clock();

    assert(memory[0x20] == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "DEC zp: neg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0xC6;
    memory[0x1] = 0x20;
    memory[0x20] = 0xFF;

    cpu.clock();

    assert(memory[0x20] == 0xFE);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "INY: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0xFF,
    };

    memory[0x0] = 0xC8;

    cpu.clock();

    assert(cpu.y == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 1);
}

test "INY: negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .y = 0xFE,
        .status = 0b00000000,
    };

    memory[0x0] = 0xC8;

    cpu.clock();

    assert(cpu.y == 0xFF);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 1);
}

test "DEX: negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0x0,
    };

    memory[0x0] = 0xCA;

    cpu.clock();

    assert(cpu.status == 0b10000000);
    assert(cpu.x == 0xFF);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "DEX: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0x1,
    };

    memory[0x0] = 0xCA;

    cpu.clock();

    assert(cpu.status == 0b00000010);
    assert(cpu.x == 0);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "BNE rel" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0xFD,
        .status = 0b00000000,
    };

    memory[0xFD] = 0xD0;
    memory[0xFE] = 0x05;
    memory[0x0104] = 0x03;

    cpu.clock();

    assert(cpu.pc == 0x0104);
    assert(cpu.cycles == 3);
}

test "BNE rel: no branch" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000010,
    };

    memory[0x0] = 0xD0;
    memory[0x1] = 0x05;

    cpu.clock();

    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 1);
}

test "CLD" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00001000,
    };

    memory[0x0] = 0xD8;

    cpu.clock();

    assert(cpu.status == 0b00000000);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}

test "SBC zp: no overflow, negative, borrow" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0xFF,
        .status = 0b00000000,
    };

    memory[0x0] = 0xE5;
    memory[0x1] = 0x20;
    memory[0x20] = 0x2;

    cpu.clock();

    assert(cpu.pc == 0x2);
    assert(cpu.ac == 0xFC);
    assert(cpu.status == 0b10000001);
    assert(cpu.cycles == 2);
}

test "SBC zp: overflow, no borrow" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x0,
        .ac = 0xFA,
        .status = 0b00000001,
    };

    memory[0x0] = 0xE5;
    memory[0x1] = 0x20;
    memory[0x20] = 0x7F;

    cpu.clock();

    assert(cpu.pc == 0x2);
    assert(cpu.ac == 0x7B);
    assert(cpu.status == 0b01000001);
    assert(cpu.cycles == 2);
}

test "CPX imm: non-negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0x20,
    };

    memory[0x0] = 0xE0;
    memory[0x1] = 0x10;

    cpu.clock();

    assert(cpu.status == 0b00000001);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "CPX imm: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0x20,
    };

    memory[0x0] = 0xE0;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(cpu.status == 0b00000011);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "CPX imm: negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0x10,
        .status = 0b00000000,
    };

    memory[0x0] = 0xE0;
    memory[0x1] = 0x20;

    cpu.clock();

    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 1);
}

test "INC zp: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0xE6;
    memory[0x1] = 0x20;
    memory[0x20] = 0xFF;

    cpu.clock();

    assert(memory[0x20] == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "INC zp: neg" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0xE6;
    memory[0x1] = 0x20;
    memory[0x20] = 0xFE;

    cpu.clock();

    assert(memory[0x20] == 0xFF);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x2);
    assert(cpu.cycles == 4);
}

test "INX: zero" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0xFF,
    };

    memory[0x0] = 0xE8;

    cpu.clock();

    assert(cpu.x == 0x0);
    assert(cpu.status == 0b00000010);
    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 1);
}

test "INX: negative" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .x = 0xFE,
        .status = 0b00000000,
    };

    memory[0x0] = 0xE8;

    cpu.clock();

    assert(cpu.x == 0xFF);
    assert(cpu.status == 0b10000000);
    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 1);
}

test "NOP" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
    };

    memory[0x0] = 0xEA;

    cpu.clock();

    assert(cpu.pc == 0x1);
    assert(cpu.cycles == 1);
}

test "BEQ rel" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0xFD,
        .status = 0b00000010,
    };

    memory[0xFD] = 0xF0;
    memory[0xFE] = 0x05;
    memory[0x0104] = 0x03;

    cpu.clock();

    assert(cpu.pc == 0x0104);
    assert(cpu.cycles == 3);
}

test "BEQ rel: no branch" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0xF0;
    memory[0x1] = 0x05;

    cpu.clock();

    assert(cpu.pc == 0x02);
    assert(cpu.cycles == 1);
}

test "SED" {
    var memory = [_]u8{0} ** (64 * 1024);
    var cpu = Emulated6502{
        .bus = &Bus.init(&memory),
        .pc = 0x00,
        .status = 0b00000000,
    };

    memory[0x0] = 0xF8;

    cpu.clock();

    assert(cpu.status == 0b00001000);
    assert(cpu.pc == 0x01);
    assert(cpu.cycles == 1);
}
