const std = @import("std");
const assert = std.debug.assert;
const instructions = @import("../../src/cpu/op_codes.zig");
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

test "BMI" {
    
}
