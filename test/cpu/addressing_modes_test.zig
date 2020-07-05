const std = @import("std");
const cpu = @import("./cpu.zig");

pub fn imm(cpu: *cpu.Emulated6502) void {
    cpu.operand = cpu.read(cpu.pc);
    cpu.pc += 1;
}
