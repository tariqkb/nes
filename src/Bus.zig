pub const Bus = struct {
    memory: *[64 * 1024]u8,

    pub fn init(memory: *[64 * 1024]u8) Bus {
        return Bus{
            .memory = memory,
        };
    }

    pub fn read(self: *Bus, addr: u16) u8 {
        return self.memory[addr];
    }

    pub fn write(self: *Bus, addr: u16, byte: u8) void {
        self.memory[addr] = byte;
    }
};
