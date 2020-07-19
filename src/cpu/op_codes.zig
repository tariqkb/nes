const std = @import("std");
const Emulated6502 = @import("./cpu.zig").Emulated6502;
const am = @import("./addressing_modes.zig");
const as = @import("builtin").as;

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

fn ORA(cpu: *Emulated6502) u8 {
    cpu.ac = cpu.ac | cpu.operand;

    cpu.
    return 1;
}

fn ASL(cpu: *Emulated6502) u8 {
    return 0;
}

fn AND(cpu: *Emulated6502) u8 {
    cpu.ac = cpu.ac & cpu.operand;
    return 1;
}

pub const op_codes = [_]OpCode{
    OpCode{
        .code = 0x00,
        .name = "XXX #",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = 0,
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
        .name = "XXX #",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = 0,
    },
    OpCode{
        .code = 0x03,
        .name = "XXX #",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = 0,
    },
    OpCode{
        .code = 0x04,
        .name = "XXX #",
        .operation = invalidOpCode,
        .addr_mode = am.imm,
        .cycles = 0,
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
};
