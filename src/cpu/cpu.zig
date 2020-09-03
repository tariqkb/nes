const std = @import("std");
const Bus = @import("../Bus.zig").Bus;
const op_codes = @import("./op_codes.zig").op_codes;
const OpCode = @import("./op_codes.zig").OpCode;

// todo find out what it's supposed to be
const CLOCK_RATE_6502 = 1790000;

pub const Emulated6502 = struct {
    bus: *Bus,
    ac: u8 = 0,
    x: u8 = 0,
    y: u8 = 0,
    status: u8 = 0,
    stkp: u8 = 0xFF,
    pc: u16 = 0,

    operand_addr: u16 = 0,
    operand: u8 = 0,

    op_code: ?OpCode = null,

    cycles: u8 = 0,

    pub fn clock(self: *Emulated6502) void {
        if (self.cycles == 0) {
            const op_code_byte = self.read(self.pc);
            self.pc += 1;

            const op_code = op_codes[op_code_byte];
            self.op_code = op_code;

            // std.debug.warn("[opcode] {} operand={} addr={}\n", .{ op_code.name, self.operand, self.operand_addr });
            const extra_cycle = op_code.addr_mode(self) & op_code.operation(self);

            const op_code_cycles = op_code.cycles orelse unreachable;

            self.cycles += op_code_cycles + extra_cycle;
        }

        self.cycles -= 1;
    }

    pub fn reset(self: *Emulated6502) void {
        self.ac = 0;
        self.x = 0;
        self.y = 0;
        self.status = 0 | @enumToInt(StatusFlag.U);
        self.stkp = 0xFF;
        self.pc = self.read16(0xFFFC);

        self.operand_addr = 0x0;
        self.operand = 0;
        self.op_code = null;

        self.cycles = 8;
    }

    pub fn irq(self: *Emulated6502) void {
        if (self.getFlag(StatusFlag.I)) return;

        self.write(0x0100 + self.stkp, @truncate(u8, self.pc >> 8));
        self.stkp -= 1;
        self.write(0x0100 + self.stkp, @truncate(u8, self.pc));
        self.stkp -= 1;
    }

    pub fn getFlag(self: *Emulated6502, flag: StatusFlag) bool {
        return self.status & @enumToInt(flag) != 0;
    }

    pub fn setFlag(self: *Emulated6502, flag: StatusFlag, is_set: bool) void {
        if (is_set) {
            self.status |= @enumToInt(flag);
        } else {
            self.status &= ~@enumToInt(flag);
        }
    }

    pub fn stackPush(self: *Emulated6502, value: u8) void {
        cpu.write(0x0100 + @as(u16, cpu.stkp), value);
        cpu.stkp -= 1;
    }

    pub fn write(self: *Emulated6502, addr: u16, value: u8) void {
        self.bus.write(addr, value);
    }

    pub fn read(self: *Emulated6502, addr: u16) u8 {
        return self.bus.read(addr);
    }

    pub fn read16(self: *Emulated6502, addr: u16) u16 {
        const lo = self.bus.read(addr);
        const hi: u16 = self.bus.read(addr + 1);

        return hi << 8 | lo;
    }

    pub fn log(self: *Emulated6502) void {
        std.debug.warn("[state] {}\n", .{self});
    }
};

pub const StatusFlag = enum(u8) {
    N = 1 << 7, // negative
    V = 1 << 6, // overflow
    U = 1 << 5, // unused
    B = 1 << 4, // break
    D = 1 << 3, // decimal
    I = 1 << 2, // interrupt
    Z = 1 << 1, // zero
    C = 1 << 0, // carry
};
