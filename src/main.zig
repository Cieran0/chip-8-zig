//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

const MemoryAddressError = error{
    RESERVED_ADDRESS,
    INVALID_ADDRESS
};

const RegisterError = error{
    INVALID_REGISTER,
    ATTEMPT_TO_WRITE_VF,
};

var memory_space: [4096]u8 = [_]u8{0}**4096;

var registers_VX: [16]u8 = [_]u8{0}**16; 

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)

    try stdout.print("Hello, World{c}\n", .{'!'});


    try stdout.print("{d}\n", .{@sizeOf(u8) * memory_space.len});

    // setMem(540, 50) catch |err| {
    //     switch (err) {
    //         MemoryAddressError.RESERVED_ADDRESS => {},
    //         MemoryAddressError.INVALID_ADDRESS => {},
    //     }
    //     try stdout.print("ARGGGG!\n",.{});
    // };

    var x: u16 = 0xE000;
    flip(&x);
    const y: u12 = @intCast( (x << 4) & 0xFFF );
    try stdout.print("{x}\n" ,.{get_nimble(x,0)});
    try stdout.print("{x}\n" ,.{y});
}

pub fn get_nimble(value :u16, nible: u4) u16 {
    return (value >> (nible*4)) & 0xF;
}

pub fn flip(num: *u16) void {
    num.* = @byteSwap(num.*);
}

pub fn write_to_register(vx: u8, data: u8) !void {
    if(vx < 0) {
        return RegisterError.INVALID_REGISTER;
    } else if (vx >= 0xF) {
        return RegisterError.ATTEMPT_TO_WRITE_VF;
    }
    registers_VX[vx] = data;
}

pub fn read_from_register(vx: u8) !u8 {
    if(vx < 0) {
        return RegisterError.INVALID_REGISTER;
    }
    return registers_VX[vx];
}

pub fn write_to_memory(address: u16, data: u8) !void {
    if(address <= 0x1FF) {
        return MemoryAddressError.RESERVED_ADDRESS;
    } else if (address > 0xFFF) {
        return MemoryAddressError.INVALID_ADDRESS;
    }
    memory_space[address] = data;
}

pub fn read_from_memory(address: u16) !u8 {
    if(address <= 0x1FF) {
        //TODO: idk if this is allowed or not
        //return MemoryAddressError.RESERVED_ADDRESS;
    } else if (address > 0xFFF) {
        return MemoryAddressError.INVALID_ADDRESS;
    }
    return memory_space[address];
}

