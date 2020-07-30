const std = @import("std");
const Emulated6502 = @import("./cpu.zig").Emulated6502;
const as = @import("builtin").as;

pub fn acc(cpu: *Emulated6502) u8 {
    cpu.operand = cpu.ac;
    cpu.operand_addr = 0;
    return 0;
}

pub fn impl(cpu: *Emulated6502) u8 {
    cpu.operand = 0;
    cpu.operand_addr = 0;
    return 0;
}

pub fn imm(cpu: *Emulated6502) u8 {
    cpu.operand = cpu.read(cpu.pc);
    cpu.pc += 1;

    cpu.operand_addr = 0;
    return 0;
}

pub fn zpg(cpu: *Emulated6502) u8 {
    const addr = cpu.read(cpu.pc);
    cpu.pc += 1;

    cpu.operand_addr = addr;
    cpu.operand = cpu.read(cpu.operand_addr);
    return 0;
}

pub fn zpgX(cpu: *Emulated6502) u8 {
    const addr = cpu.read(cpu.pc);
    cpu.pc += 1;

    cpu.operand_addr = addr +% cpu.x;
    cpu.operand = cpu.read(cpu.operand_addr);
    return 0;
}

pub fn zpgY(cpu: *Emulated6502) u8 {
    const addr = cpu.read(cpu.pc);
    cpu.pc += 1;

    cpu.operand_addr = addr +% cpu.y;
    cpu.operand = cpu.read(cpu.operand_addr);
    return 0;
}

pub fn abs(cpu: *Emulated6502) u8 {
    const addr = cpu.read16(cpu.pc);
    cpu.pc += 2;

    cpu.operand_addr = addr;
    cpu.operand = cpu.read(cpu.operand_addr);
    return 0;
}

pub fn absX(cpu: *Emulated6502) u8 {
    const addr = cpu.read16(cpu.pc);
    cpu.pc += 2;

    cpu.operand_addr = addr + cpu.x;
    cpu.operand = cpu.read(cpu.operand_addr);

    if (cpu.operand_addr & 0xFF00 != addr & 0xFF00) {
        return 1;
    }
    return 0;
}

pub fn absY(cpu: *Emulated6502) u8 {
    const addr = cpu.read16(cpu.pc);
    cpu.pc += 2;

    cpu.operand_addr = addr + cpu.y;
    cpu.operand = cpu.read(cpu.operand_addr);

    if (cpu.operand_addr & 0xFF00 != addr & 0xFF00) {
        return 1;
    }
    return 0;
}

pub fn ind(cpu: *Emulated6502) u8 {
    const ptr_lo = cpu.read(cpu.pc);
    cpu.pc += 1;
    const ptr_hi: u16 = cpu.read(cpu.pc);
    cpu.pc += 1;

    const ptr = ptr_hi << 8 | ptr_lo;

    if (ptr_lo == 0xFF) {
        // bug in 6502 where crossing pages loops
        const addr_hi: u16 = cpu.read(ptr & 0xFF00);
        const addr_lo = cpu.read(ptr);

        cpu.operand_addr = addr_hi << 8 | addr_lo;
    } else {
        cpu.operand_addr = cpu.read16(ptr);
    }

    cpu.operand = cpu.read(cpu.operand_addr);
    return 0;
}

pub fn indX(cpu: *Emulated6502) u8 {
    //todo without carry? rollover or not?
    const ptr = cpu.read(cpu.pc) +% cpu.x;
    cpu.pc += 1;

    const addr = cpu.read16(ptr);

    cpu.operand_addr = addr;
    cpu.operand = cpu.read(cpu.operand_addr);
    return 0;
}

pub fn indY(cpu: *Emulated6502) u8 {
    const ptr = cpu.read(cpu.pc);
    cpu.pc += 1;

    const addr = cpu.read16(ptr);

    cpu.operand_addr = addr + cpu.y;
    cpu.operand = cpu.read(cpu.operand_addr);

    if (cpu.operand_addr & 0xFF00 != addr & 0xFF00) {
        return 1;
    }
    return 0;
}

pub fn rel(cpu: *Emulated6502) u8 {
    var offset: u16 = cpu.read(cpu.pc);
    cpu.pc += 1;

    if (offset & 0x80 > 0) {
        offset |= 0xFF00;
    }

    cpu.operand_addr = cpu.pc +% offset;
    cpu.operand = cpu.read(cpu.operand_addr);

    if (cpu.operand_addr >> 8 != cpu.pc >> 8) {
        return 1;
    }
    return 0;
}
