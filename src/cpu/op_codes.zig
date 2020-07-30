const std = @import("std");
const Emulated6502 = @import("./cpu.zig").Emulated6502;
const StatusFlag = @import("./cpu.zig").StatusFlag;
const am = @import("./addressing_modes.zig");

const addressing_mode_fn = fn (cpu: *Emulated6502) u8;
const operation_fn = fn (cpu: *Emulated6502) u8;

pub const OpCode = struct {
    code: u8,
    name: []const u8,
    operation: operation_fn,
    addr_mode: addressing_mode_fn,
    cycles: u8,
};

fn invalidOpCode(cpu: *Emulated6502) u8 {
    // todo fail
    return 0;
}

fn BRK(cpu: *Emulated6502) u8 {
    const lo = @truncate(u8, cpu.pc);
    const hi = @truncate(u8, cpu.pc >> 8);

    cpu.write(0x0100 + @as(u16, cpu.stkp), hi);
    cpu.stkp -= 1;
    cpu.write(0x0100 + @as(u16, cpu.stkp), lo);
    cpu.stkp -= 1;

    const stack_status = cpu.status | @enumToInt(StatusFlag.B);
    cpu.write(0x0100 + @as(u16, cpu.stkp), stack_status);
    cpu.stkp -= 1;

    cpu.pc = cpu.read16(0xFFFE);

    return 0;
}

fn ORA(cpu: *Emulated6502) u8 {
    cpu.ac = cpu.ac | cpu.operand;

    cpu.setFlag(StatusFlag.Z, cpu.ac == 0);
    cpu.setFlag(StatusFlag.N, cpu.ac & 0x80 != 0);

    return 1;
}

fn ASL(cpu: *Emulated6502) u8 {
    const val = @truncate(u8, cpu.operand << 1);

    cpu.setFlag(StatusFlag.Z, val == 0);
    cpu.setFlag(StatusFlag.N, (val & 0x80) != 0);
    cpu.setFlag(StatusFlag.C, (cpu.operand & 0x80) != 0);

    const op_code = cpu.op_code orelse unreachable;

    const val_lo: u8 = @truncate(u8, val);
    if (op_code.addr_mode == am.acc) {
        cpu.ac = val_lo;
    } else {
        cpu.write(cpu.operand_addr, val_lo);
    }

    return 0;
}

fn PHP(cpu: *Emulated6502) u8 {
    cpu.write(0x0100 + @as(u16, cpu.stkp), cpu.status);
    cpu.stkp -= 1;

    return 0;
}

fn BPL(cpu: *Emulated6502) u8 {
    if (!cpu.getFlag(StatusFlag.N)) {
        cpu.pc = cpu.operand_addr;
        cpu.cycles += 1;
        return 1;
    }

    return 0;
}

fn CLC(cpu: *Emulated6502) u8 {
    cpu.setFlag(StatusFlag.C, false);

    return 0;
}

fn JSR(cpu: *Emulated6502) u8 {
    const stack_pc = cpu.pc - 1;
    const lo = @truncate(u8, stack_pc);
    const hi = @truncate(u8, stack_pc >> 8);

    cpu.write(0x0100 + @as(u16, cpu.stkp), hi);
    cpu.stkp -= 1;
    cpu.write(0x0100 + @as(u16, cpu.stkp), lo);
    cpu.stkp -= 1;

    cpu.pc = cpu.operand_addr;

    return 0;
}

fn AND(cpu: *Emulated6502) u8 {
    cpu.ac = cpu.ac & cpu.operand;

    cpu.setFlag(StatusFlag.Z, cpu.ac == 0);
    cpu.setFlag(StatusFlag.N, cpu.ac & 0x80 != 0);

    return 1;
}

fn BIT(cpu: *Emulated6502) u8 {
    cpu.setFlag(StatusFlag.N, cpu.operand & @enumToInt(StatusFlag.N) != 0);
    cpu.setFlag(StatusFlag.V, cpu.operand & @enumToInt(StatusFlag.V) != 0);
    cpu.setFlag(StatusFlag.Z, cpu.operand & cpu.ac == 0);

    return 0;
}

fn ROL(cpu: *Emulated6502) u8 {
    var result: u8 = undefined;
    const overflow = @shlWithOverflow(u8, cpu.operand, 1, &result);
    if (cpu.getFlag(StatusFlag.C)) {
        result |= 0b00000001;
    }

    cpu.setFlag(StatusFlag.C, overflow);
    cpu.setFlag(StatusFlag.Z, result == 0);
    cpu.setFlag(StatusFlag.N, result & 0x80 != 0);

    const op_code = cpu.op_code orelse unreachable;

    if (op_code.addr_mode == am.acc) {
        cpu.ac = result;
    } else {
        cpu.write(cpu.operand_addr, result);
    }
    return 0;
}

fn PLP(cpu: *Emulated6502) u8 {
    cpu.stkp -= 1;
    cpu.status = cpu.read(0x0100 + @as(u16, cpu.stkp));

    return 0;
}

fn BMI(cpu: *Emulated6502) u8 {
    return 0;
}

fn SEC(cpu: *Emulated6502) u8 {
    return 0;
}

fn RTI(cpu: *Emulated6502) u8 {
    return 0;
}

fn EOR(cpu: *Emulated6502) u8 {
    return 0;
}

fn LSR(cpu: *Emulated6502) u8 {
    return 0;
}

fn PHA(cpu: *Emulated6502) u8 {
    return 0;
}

fn BVC(cpu: *Emulated6502) u8 {
    return 0;
}

fn CLI(cpu: *Emulated6502) u8 {
    return 0;
}

fn ADC(cpu: *Emulated6502) u8 {
    return 0;
}

fn PLA(cpu: *Emulated6502) u8 {
    return 0;
}

fn ROR(cpu: *Emulated6502) u8 {
    return 0;
}

fn BVS(cpu: *Emulated6502) u8 {
    return 0;
}

fn SEI(cpu: *Emulated6502) u8 {
    return 0;
}

fn STA(cpu: *Emulated6502) u8 {
    return 0;
}

fn STY(cpu: *Emulated6502) u8 {
    return 0;
}

fn STX(cpu: *Emulated6502) u8 {
    return 0;
}

fn DEY(cpu: *Emulated6502) u8 {
    return 0;
}

fn TXA(cpu: *Emulated6502) u8 {
    return 0;
}

fn BCC(cpu: *Emulated6502) u8 {
    return 0;
}

fn TYA(cpu: *Emulated6502) u8 {
    return 0;
}

fn TXS(cpu: *Emulated6502) u8 {
    return 0;
}

fn BBS1(cpu: *Emulated6502) u8 {
    return 0;
}

fn LDY(cpu: *Emulated6502) u8 {
    return 0;
}

fn LDA(cpu: *Emulated6502) u8 {
    return 0;
}

fn LDX(cpu: *Emulated6502) u8 {
    return 0;
}

fn TAY(cpu: *Emulated6502) u8 {
    return 0;
}

fn TAX(cpu: *Emulated6502) u8 {
    return 0;
}

fn BCS(cpu: *Emulated6502) u8 {
    return 0;
}

fn CLV(cpu: *Emulated6502) u8 {
    return 0;
}

fn TSX(cpu: *Emulated6502) u8 {
    return 0;
}

fn CPY(cpu: *Emulated6502) u8 {
    return 0;
}

fn CMP(cpu: *Emulated6502) u8 {
    return 0;
}

fn DEC(cpu: *Emulated6502) u8 {
    return 0;
}

fn INY(cpu: *Emulated6502) u8 {
    return 0;
}

fn DEX(cpu: *Emulated6502) u8 {
    return 0;
}

fn BNE(cpu: *Emulated6502) u8 {
    return 0;
}

fn CLD(cpu: *Emulated6502) u8 {
    return 0;
}

fn SBC(cpu: *Emulated6502) u8 {
    return 0;
}

fn CPX(cpu: *Emulated6502) u8 {
    return 0;
}

fn INC(cpu: *Emulated6502) u8 {
    return 0;
}

fn INX(cpu: *Emulated6502) u8 {
    return 0;
}

fn NOP(cpu: *Emulated6502) u8 {
    return 0;
}

fn BEQ(cpu: *Emulated6502) u8 {
    return 0;
}

fn SED(cpu: *Emulated6502) u8 {
    return 0;
}

pub const op_codes = [_]OpCode{

    // ====
    // 0x00
    // ====
    OpCode{
        .code = 0x00,
        .name = "BRK",
        .operation = BRK,
        .addr_mode = am.impl,
        .cycles = 7,
    },
    OpCode{
        .code = 0x01,
        .name = "ORA X,ind",
        .operation = ORA,
        .addr_mode = am.indX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x02,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x03,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x04,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x05,
        .name = "ORA zpg",
        .operation = ORA,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0x06,
        .name = "ASL zpg",
        .operation = ASL,
        .addr_mode = am.zpg,
        .cycles = 5,
    },
    OpCode{
        .code = 0x07,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x08,
        .name = "PHP",
        .operation = PHP,
        .addr_mode = am.impl,
        .cycles = 3,
    },
    OpCode{
        .code = 0x09,
        .name = "ORA #",
        .operation = ORA,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0x0A,
        .name = "ASL #",
        .operation = ASL,
        .addr_mode = am.acc,
        .cycles = 2,
    },
    OpCode{
        .code = 0x0B,
        .name = "ASL #",
        .operation = ASL,
        .addr_mode = am.acc,
        .cycles = 2,
    },
    OpCode{
        .code = 0x0C,
        .name = "ASL #",
        .operation = ASL,
        .addr_mode = am.acc,
        .cycles = 2,
    },
    OpCode{
        .code = 0x0D,
        .name = "ORA abs",
        .operation = ORA,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x0E,
        .name = "ASL abs",
        .operation = ASL,
        .addr_mode = am.abs,
        .cycles = 6,
    },
    OpCode{
        .code = 0x0F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ====
    // 0x10
    // ====

    OpCode{
        .code = 0x10,
        .name = "BPL rel",
        .operation = BPL,
        .addr_mode = am.rel,
        .cycles = 2,
    },
    OpCode{
        .code = 0x11,
        .name = "ORA ind,y",
        .operation = ORA,
        .addr_mode = am.indY,
        .cycles = 5,
    },
    OpCode{
        .code = 0x12,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x13,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x14,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x15,
        .name = "ORA zpg,x",
        .operation = ORA,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x16,
        .name = "ASL zpg,x",
        .operation = ASL,
        .addr_mode = am.zpgX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x17,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x18,
        .name = "CLC",
        .operation = CLC,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0x19,
        .name = "ORA abs,Y",
        .operation = ORA,
        .addr_mode = am.absY,
        .cycles = 4,
    },
    OpCode{
        .code = 0x1A,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x1B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x1C,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x1D,
        .name = "ORA abs,X",
        .operation = ORA,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x1E,
        .name = "ASL abs,X",
        .operation = ASL,
        .addr_mode = am.absX,
        .cycles = 7,
    },
    OpCode{
        .code = 0x1F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ====
    // 0x20
    // ====

    OpCode{
        .code = 0x20,
        .name = "JSR abs",
        .operation = JSR,
        .addr_mode = am.abs,
        .cycles = 6,
    },
    OpCode{
        .code = 0x21,
        .name = "AND ind,X",
        .operation = AND,
        .addr_mode = am.indX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x22,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x23,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x24,
        .name = "BIT zpg",
        .operation = BIT,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0x25,
        .name = "AND zpg",
        .operation = AND,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0x26,
        .name = "ROL zpg",
        .operation = ROL,
        .addr_mode = am.zpg,
        .cycles = 5,
    },
    OpCode{
        .code = 0x27,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x28,
        .name = "PLP",
        .operation = PLP,
        .addr_mode = am.impl,
        .cycles = 4,
    },
    OpCode{
        .code = 0x29,
        .name = "AND #",
        .operation = AND,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0x2A,
        .name = "ROL A",
        .operation = ROL,
        .addr_mode = am.acc,
        .cycles = 2,
    },
    OpCode{
        .code = 0x2B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x2C,
        .name = "BIT abs",
        .operation = BIT,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x2D,
        .name = "AND abs",
        .operation = AND,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x2E,
        .name = "ROL abs",
        .operation = ROL,
        .addr_mode = am.abs,
        .cycles = 6,
    },
    OpCode{
        .code = 0x2F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ====
    // 0x30
    // ====

    OpCode{
        .code = 0x30,
        .name = "BML rel",
        .operation = BMI,
        .addr_mode = am.rel,
        .cycles = 2,
    },
    OpCode{
        .code = 0x31,
        .name = "AND ind,y",
        .operation = AND,
        .addr_mode = am.indY,
        .cycles = 5,
    },

    OpCode{
        .code = 0x32,
        .name = "AND ind",
        .operation = AND,
        .addr_mode = am.ind,
        .cycles = 5,
    },
    OpCode{
        .code = 0x33,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x34,
        .name = "BIT zpg",
        .operation = BIT,
        .addr_mode = am.zpg,
        .cycles = 4,
    },
    OpCode{
        .code = 0x35,
        .name = "AND zpg,X",
        .operation = AND,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x36,
        .name = "ROL zpg,X",
        .operation = ROL,
        .addr_mode = am.zpgX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x37,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x38,
        .name = "SEC",
        .operation = SEC,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0x39,
        .name = "AND abs,Y",
        .operation = AND,
        .addr_mode = am.absY,
        .cycles = 4,
    },
    OpCode{
        .code = 0x3A,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x3B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x3C,
        .name = "BIT abs,X",
        .operation = BIT,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x3D,
        .name = "AND abs,X",
        .operation = AND,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x3E,
        .name = "ROL abs,X",
        .operation = ROL,
        .addr_mode = am.absX,
        .cycles = 7,
    },
    OpCode{
        .code = 0x3F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0x40
    // ===

    OpCode{
        .code = 0x40,
        .name = "RTI",
        .operation = RTI,
        .addr_mode = am.impl,
        .cycles = 6,
    },
    OpCode{
        .code = 0x41,
        .name = "EOR ind,X",
        .operation = EOR,
        .addr_mode = am.indX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x42,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x43,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x44,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x45,
        .name = "EOR zpg",
        .operation = EOR,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0x46,
        .name = "LSR zpg",
        .operation = LSR,
        .addr_mode = am.zpg,
        .cycles = 5,
    },
    OpCode{
        .code = 0x47,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x48,
        .name = "PHA",
        .operation = PHA,
        .addr_mode = am.impl,
        .cycles = 3,
    },
    OpCode{
        .code = 0x49,
        .name = "EOR #",
        .operation = EOR,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0x4A,
        .name = "LSR A",
        .operation = LSR,
        .addr_mode = am.acc,
        .cycles = 2,
    },
    OpCode{
        .code = 0x4B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x4C,
        .name = "JMP abs",
        .operation = JMP,
        .addr_mode = am.abs,
        .cycles = 3,
    },
    OpCode{
        .code = 0x4D,
        .name = "EOR abs",
        .operation = EOR,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x4E,
        .name = "LSR abs",
        .operation = LSR,
        .addr_mode = am.abs,
        .cycles = 6,
    },
    OpCode{
        .code = 0x4F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0x50
    // ===

    OpCode{
        .code = 0x50,
        .name = "BVC rel",
        .operation = BVC,
        .addr_mode = am.rel,
        .cycles = 2,
    },
    OpCode{
        .code = 0x51,
        .name = "EOR ind,Y",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = 5,
    },
    OpCode{
        .code = 0x52,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x53,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x54,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x55,
        .name = "EOR zpg,X",
        .operation = EOR,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x56,
        .name = "LSR zpg,X",
        .operation = LSR,
        .addr_mode = am.zpgX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x57,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x58,
        .name = "CLI",
        .operation = CLI,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0x59,
        .name = "EOR abs,Y",
        .operation = EOR,
        .addr_mode = am.absY,
        .cycles = 4,
    },
    OpCode{
        .code = 0x5A,
        .name = "PHY",
        .operation = PHY,
        .addr_mode = am.impl,
        .cycles = 3,
    },
    OpCode{
        .code = 0x5B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x5C,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x5D,
        .name = "EOR abs,X",
        .operation = EOR,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x5E,
        .name = "LSR abs,X",
        .operation = LSR,
        .addr_mode = am.absX,
        .cycles = 7,
    },
    OpCode{
        .code = 0x5F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0x60
    // ===

    OpCode{
        .code = 0x60,
        .name = "RTS",
        .operation = RTS,
        .addr_mode = am.impl,
        .cycles = 6,
    },
    OpCode{
        .code = 0x61,
        .name = "ADC ind,X",
        .operation = ADC,
        .addr_mode = am.indX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x62,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x63,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x64,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x65,
        .name = "ADC",
        .operation = ADC,
        .addr_mode = am.zpg,
        .cycles = 5,
    },
    OpCode{
        .code = 0x66,
        .name = "ROR zpg",
        .operation = ROR,
        .addr_mode = am.zpg,
        .cycles = 5,
    },
    OpCode{
        .code = 0x67,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x68,
        .name = "PLA",
        .operation = PLA,
        .addr_mode = am.impl,
        .cycles = 4,
    },
    OpCode{
        .code = 0x69,
        .name = "ADC #",
        .operation = ADC,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0x6A,
        .name = "ROR A",
        .operation = ROR,
        .addr_mode = am.acc,
        .cycles = 2,
    },
    OpCode{
        .code = 0x6B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x6C,
        .name = "JMP abs",
        .operation = JMP,
        .addr_mode = am.abs,
        .cycles = 6,
    },
    OpCode{
        .code = 0x6D,
        .name = "ADC abs",
        .operation = ADC,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x6E,
        .name = "ROR abs",
        .operation = ROR,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x6F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0x70
    // ===

    OpCode{
        .code = 0x70,
        .name = "BVS rel",
        .operation = BVS,
        .addr_mode = am.rel,
        .cycles = 2,
    },
    OpCode{
        .code = 0x71,
        .name = "ADC ind,Y",
        .operation = ADC,
        .addr_mode = am.indY,
        .cycles = 5,
    },
    OpCode{
        .code = 0x72,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x73,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x74,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x75,
        .name = "ADC zpg,X",
        .operation = ADC,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x76,
        .name = "ROR zpg,X",
        .operation = ROR,
        .addr_mode = am.zpgX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x77,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x78,
        .name = "SEI",
        .operation = SEI,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0x79,
        .name = "ADC abs,Y",
        .operation = ADC,
        .addr_mode = am.absY,
        .cycles = 4,
    },
    OpCode{
        .code = 0x7A,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x7B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x7C,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x7D,
        .name = "ADC abs,X",
        .operation = ADC,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x7E,
        .name = "ROR abs,X",
        .operation = ROR,
        .addr_mode = am.absX,
        .cycles = 7,
    },
    OpCode{
        .code = 0x7F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0x80
    // ===

    OpCode{
        .code = 0x80,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x81,
        .name = "STA ind,X",
        .operation = STA,
        .addr_mode = am.indX,
        .cycles = 6,
    },
    OpCode{
        .code = 0x82,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x83,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x84,
        .name = "STY zpg",
        .operation = STY,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0x85,
        .name = "STA zpg",
        .operation = STA,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0x86,
        .name = "STX zpg",
        .operation = STX,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0x87,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x88,
        .name = "DEY",
        .operation = DEY,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0x89,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x8A,
        .name = "TXA",
        .operation = TXA,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0x8B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x8C,
        .name = "STY abs",
        .operation = STY,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x8D,
        .name = "STA abs",
        .operation = STA,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x8E,
        .name = "STX abs",
        .operation = STX,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0x8F,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0x90
    // ===

    OpCode{
        .code = 0x90,
        .name = "BCC rel",
        .operation = BCC,
        .addr_mode = am.rel,
        .cycles = 2,
    },
    OpCode{
        .code = 0x91,
        .name = "STA ind,Y",
        .operation = STA,
        .addr_mode = am.indY,
        .cycles = 6,
    },
    OpCode{
        .code = 0x92,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x93,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x94,
        .name = "STY zpg,X",
        .operation = STY,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0x95,
        .name = "STA zpg,X",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = 4,
    },
    OpCode{
        .code = 0x96,
        .name = "STX zpg,Y",
        .operation = STX,
        .addr_mode = am.zpgY,
        .cycles = 4,
    },
    OpCode{
        .code = 0x97,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x98,
        .name = "TYA",
        .operation = TYA,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0x99,
        .name = "STA abs,Y",
        .operation = STA,
        .addr_mode = am.absY,
        .cycles = 5,
    },
    OpCode{
        .code = 0x9A,
        .name = "TXS",
        .operation = TXS,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0x9B,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x9C,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x9D,
        .name = "STA abs,X",
        .operation = STA,
        .addr_mode = am.absX,
        .cycles = 5,
    },
    OpCode{
        .code = 0x9E,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0x9F,
        .name = "BBS1 zpg",
        .operation = BBS1,
        .addr_mode = am.zpg,
        .cycles = 5,
    },

    // ===
    // 0xA0
    // ===

    OpCode{
        .code = 0xA0,
        .name = "LDY #",
        .operation = LDY,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0xA1,
        .name = "LDA ind,X",
        .operation = LDA,
        .addr_mode = am.indX,
        .cycles = 6,
    },
    OpCode{
        .code = 0xA2,
        .name = "LDX #",
        .operation = LDX,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0xA3,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xA4,
        .name = "LDY zpg",
        .operation = LDY,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0xA5,
        .name = "LDA zpg",
        .operation = LDA,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0xA6,
        .name = "LDX zpg",
        .operation = LDX,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0xA7,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xA8,
        .name = "TAY",
        .operation = TAY,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xA9,
        .name = "LDA #",
        .operation = LDA,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0xAA,
        .name = "TAX",
        .operation = TAX,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xAB,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xAC,
        .name = "LDY abs",
        .operation = LDY,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0xAD,
        .name = "LDA abs",
        .operation = LDA,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0xAE,
        .name = "LDX",
        .operation = LDX,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0xAF,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0xB0
    // ===

    OpCode{
        .code = 0xB0,
        .name = "BCS rel",
        .operation = BCS,
        .addr_mode = am.rel,
        .cycles = 2,
    },
    OpCode{
        .code = 0xB1,
        .name = "LDA ind,Y",
        .operation = LDA,
        .addr_mode = am.indY,
        .cycles = 5,
    },
    OpCode{
        .code = 0xB2,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xB3,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xB4,
        .name = "LDY zpg,X",
        .operation = LDY,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0xB5,
        .name = "LDA zpg,X",
        .operation = LDA,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0xB6,
        .name = "LDX zpg,Y",
        .operation = LDX,
        .addr_mode = am.zpgY,
        .cycles = 4,
    },
    OpCode{
        .code = 0xB7,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xB8,
        .name = "CLV",
        .operation = CLV,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xB9,
        .name = "LDA abs,Y",
        .operation = LDA,
        .addr_mode = am.absY,
        .cycles = 4,
    },
    OpCode{
        .code = 0xBA,
        .name = "TSX",
        .operation = TSX,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xBB,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xBC,
        .name = "LDY abs,X",
        .operation = LSY,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0xBD,
        .name = "LDA abs,X",
        .operation = LDA,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0xBE,
        .name = "LDX abs,Y",
        .operation = LDX,
        .addr_mode = am.absY,
        .cycles = 4,
    },
    OpCode{
        .code = 0xBF,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0xC0
    // ===

    OpCode{
        .code = 0xC0,
        .name = "CPY #",
        .operation = CPY,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0xC1,
        .name = "CMP ind,X",
        .operation = CMP,
        .addr_mode = am.indX,
        .cycles = 6,
    },
    OpCode{
        .code = 0xC2,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xC3,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xC4,
        .name = "CPY zpg",
        .operation = CPY,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0xC5,
        .name = "CMP zpg",
        .operation = CMP,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0xC6,
        .name = "DEC zpg",
        .operation = DEC,
        .addr_mode = am.zpg,
        .cycles = 5,
    },
    OpCode{
        .code = 0xC7,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xC8,
        .name = "INY",
        .operation = INY,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xC9,
        .name = "CMP #",
        .operation = CMP,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0xCA,
        .name = "DEX",
        .operation = DEX,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xCB,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xCC,
        .name = "CPY abs",
        .operation = CPY,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0xCD,
        .name = "CMP abs",
        .operation = CMP,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0xCE,
        .name = "DEC abs",
        .operation = DEC,
        .addr_mode = am.abs,
        .cycles = 6,
    },
    OpCode{
        .code = 0xCF,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0xD0
    // ===

    OpCode{
        .code = 0xD0,
        .name = "BNE rel",
        .operation = BNE,
        .addr_mode = am.rel,
        .cycles = 2,
    },
    OpCode{
        .code = 0xD1,
        .name = "CMP",
        .operation = CMP,
        .addr_mode = am.indY,
        .cycles = 5,
    },
    OpCode{
        .code = 0xD2,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xD3,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xD4,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xD5,
        .name = "CMP zpg,X",
        .operation = CMP,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0xD6,
        .name = "DEC zpg,X",
        .operation = DEC,
        .addr_mode = am.zpgX,
        .cycles = 6,
    },
    OpCode{
        .code = 0xD7,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xD8,
        .name = "CLD",
        .operation = CLD,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xD9,
        .name = "CMP abs,Y",
        .operation = CMP,
        .addr_mode = am.absY,
        .cycles = 4,
    },
    OpCode{
        .code = 0xDA,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xDB,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xDC,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xDD,
        .name = "CMP abs,X",
        .operation = CMP,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0xDE,
        .name = "DEC",
        .operation = DEC,
        .addr_mode = am.absX,
        .cycles = 7,
    },
    OpCode{
        .code = 0xDF,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0xE0
    // ===

    OpCode{
        .code = 0xE0,
        .name = "CPX #",
        .operation = CPX,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0xE1,
        .name = "SBC ind,X",
        .operation = SBC,
        .addr_mode = am.indX,
        .cycles = 6,
    },
    OpCode{
        .code = 0xE2,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xE3,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xE4,
        .name = "CPX zpg",
        .operation = CPX,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0xE5,
        .name = "SBC zpg",
        .operation = SBC,
        .addr_mode = am.zpg,
        .cycles = 3,
    },
    OpCode{
        .code = 0xE6,
        .name = "INC zpg",
        .operation = INC,
        .addr_mode = am.zpg,
        .cycles = 5,
    },
    OpCode{
        .code = 0xE7,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xE8,
        .name = "INX",
        .operation = INX,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xE9,
        .name = "SBC #",
        .operation = SBC,
        .addr_mode = am.imm,
        .cycles = 2,
    },
    OpCode{
        .code = 0xEA,
        .name = "NOP",
        .operation = NOP,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xEB,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xEC,
        .name = "CPX abs",
        .operation = CPX,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0xED,
        .name = "SBC abs",
        .operation = SBC,
        .addr_mode = am.abs,
        .cycles = 4,
    },
    OpCode{
        .code = 0xEE,
        .name = "INC abs",
        .operation = INC,
        .addr_mode = am.abs,
        .cycles = 6,
    },
    OpCode{
        .code = 0xEF,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },

    // ===
    // 0xF0
    // ===

    OpCode{
        .code = 0xF0,
        .name = "BEQ rel",
        .operation = BEQ,
        .addr_mode = am.rel,
        .cycles = 2,
    },
    OpCode{
        .code = 0xF1,
        .name = "SBC ind,Y",
        .operation = SBC,
        .addr_mode = am.indY,
        .cycles = 5,
    },
    OpCode{
        .code = 0xF2,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xF3,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xF4,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xF5,
        .name = "SBC zpg,X",
        .operation = SBC,
        .addr_mode = am.zpgX,
        .cycles = 4,
    },
    OpCode{
        .code = 0xF6,
        .name = "INC zpg,X",
        .operation = INC,
        .addr_mode = am.zpgX,
        .cycles = 6,
    },
    OpCode{
        .code = 0xF7,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xF8,
        .name = "SED",
        .operation = SED,
        .addr_mode = am.impl,
        .cycles = 2,
    },
    OpCode{
        .code = 0xF9,
        .name = "SBC abs,Y",
        .operation = SBC,
        .addr_mode = am.absY,
        .cycles = 4,
    },
    OpCode{
        .code = 0xFA,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xFB,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xFC,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
    OpCode{
        .code = 0xFD,
        .name = "SBC abs,X",
        .operation = SBC,
        .addr_mode = am.absX,
        .cycles = 4,
    },
    OpCode{
        .code = 0xFE,
        .name = "INC abs,X",
        .operation = INC,
        .addr_mode = am.absX,
        .cycles = 7,
    },
    OpCode{
        .code = 0xFF,
        .name = "XXX",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = null,
    },
};
