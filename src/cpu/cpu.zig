const std = @import("std");
const Bus = @import("../Bus.zig").Bus;

pub const Emulated6502 = struct {
    bus: *Bus,
    ac: u8 = 0,
    x: u8 = 0,
    y: u8 = 0,
    status: u8 = 0,
    stkp: u8 = 0,
    pc: u16 = 0,

    // value resolved from addressing mode
    operand: u8 = 0,

    pub fn runOperation(self: *Emulated6502) void {
        const op_code = self.read(self.pc);
        self.pc += 1;
    }

    pub fn reset(self: *Emulated6502) void {
        self.ac = 0;
        self.x = 0;
        self.y = 0;
        self.status = 0;
        self.stkp = 0;
        self.pc = 0;

        self.operand = 0;
    }

    pub fn setStatus(self: *Emulated6502, status: StatusRegister) void {
        self.status = @enumToInt(status);
    }

    pub fn write(self: *Emulated6502, addr: u16, value: u8) void {
        self.bus.write(addr, value);
    }

    pub fn read(self: *Emulated6502, addr: u16) u8 {
        return self.bus.read(addr);
    }
};

pub const StatusRegister = enum(u8) {
    N = 1 << 7,
    V = 1 << 6,
    B = 1 << 4,
    D = 1 << 3,
    I = 1 << 2,
    Z = 1 << 1,
    C = 1 << 0,
};
