const C = @cImport(@cInclude("string.h"));

const std = @import("std");

const mymessage = @import("./mymessage.zig");
const handlers = @import("./handlers.zig");
const mappings = @import("./mappings.zig");

export fn mymessage_init() callconv(.C) u16 {
    mymessage.init() catch |err| {
        return @intFromError(err);
    };
    return 0;
}

export fn mymessage_deinit() callconv(.C) void {
    mymessage.deinit();
}

export fn mymessage_getMessage(
    handler_key: [*]const u8,
    postfix: [*]const u8,
) callconv(.C) [*]const u8 {
    var handler_key_ex: [mappings.key_length]u8 = undefined;
    _ = C.memcpy(&handler_key_ex, handler_key, mappings.key_length);

    const postfix_len: usize = C.strlen(postfix);

    const message = mymessage.getMessage(&handler_key_ex, postfix[0..postfix_len]) catch |err| block: {
        std.log.err("Failed to get message; [{!}]", .{err});
        break :block null;
    };
    return @ptrCast(message);
}
