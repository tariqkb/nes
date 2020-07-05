const Emulated6502 = @import("./cpu.zig").Emulated6502;

pub fn imm(cpu: *Emulated6502) void {
    cpu.operand = cpu.bus.read(cpu.pc);
    cpu.pc += 1;
}