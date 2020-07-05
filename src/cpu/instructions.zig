const std = @import("std");
const Emulated6502 = @import("./cpu.zig").Emulated6502;
const am = @import("./addressing_modes.zig");

const addressing_mode_fn = fn (cpu: *Emulated6502) void;
const operation_fn = fn (cpu: *Emulated6502) void;

const OpCode = struct {
    c: u8,
    n: []const u8,
    o: operation_fn,
    a: addressing_mode_fn,
};

fn andOp(cpu: *Emulated6502) void {
    return cpu.ac & operand;
}

pub const op_codes: [256]u8 = [_]u8{
    OpCode{
        .c = 0x00,
        .n = "BRK",
        .a = am.imm,
        .o = andOp,
    },
};
