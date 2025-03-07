const C = @cImport(@cInclude("string.h"));

const std = @import("std");
const handlers = @import("./handlers.zig");

var buffer = [_]u8{0} ** 256;
var fixed_buffer_allocator = std.heap.FixedBufferAllocator.init(@constCast(&buffer));
const allocator: std.mem.Allocator = fixed_buffer_allocator.allocator();

var map = std.StringArrayHashMap(*const handlers.MessageHandler)
    .init(allocator);

pub const key_length = 7;

/// Initialize the function lookup table
/// The caller is responsible for calling deinit
pub fn init() !void {
    const hello = "hello\x00\x00";
    try map.put(hello, &handlers.hello);
    std.log.debug("Registered handler [{s}]", .{hello});

    const goodbye = "goodbye";
    try map.put(goodbye, &handlers.goodbye);
    std.log.debug("Registered handler [{s}]", .{goodbye});

    // This requirement is just an excuse to show off usage of a comptime block for validation
    comptime {
        if (hello.len != key_length or
            goodbye.len != key_length)
        {
            std.log.err("Invalid key for handler map.");
            unreachable; // Compile-time assertion
        }
    }
    // note: the Grm_SingleDb_Interface is different from the structures above and
    // is missing purposely from this check note: the SecureADB2NavDb interface is
    // also different from the structures above is is also purposely missing from
    // this check
}

/// Deinitialize the function lookup table
pub fn deinit() void {
    map.deinit();
}

/// Returns one of the handler functions
pub fn getHandler(key: []const u8) ?*const handlers.MessageHandler {
    // Strip the given key down to key_length.
    // Pad with null bytes up to key_length.
    var strict_key: [key_length]u8 = [_]u8{0} ** key_length;
    _ = C.memcpy(&strict_key, @ptrCast(key), key.len);
    return map.get(&strict_key);
}
