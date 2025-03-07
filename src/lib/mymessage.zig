const std = @import("std");

const mappings = @import("mappings.zig");
const handlers = @import("handlers.zig");

// GPA instantiation must be split into two statemtents with the first declaring a mutable
//  variable and the second declaring the `const` `Allocator` object. The `GeneralPurposeAllocator`
//  must be instantiated into mutable memory, or the program will crash with a "Bus Error" when
//  it attempts to allocate memory.
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const message_allocator = gpa.allocator();

pub const MyError = error{
    Initialization,
    System,
    MemoryAllocation,
    BadRequest,
    Unknown,
};

/// The caller is responsible for calling deinit
pub fn init() MyError!void {
    mappings.init() catch |err| {
        std.log.err("Error initializing mappings [{!}]", .{err});
        return MyError.Initialization;
    };
}

pub fn deinit() void {
    mappings.deinit();
}

pub fn getMessage(handler_key: []const u8, postfix: []const u8) MyError![]const u8 {
    const handler = mappings.getHandler(handler_key) orelse {
        std.log.err("Unknown message type [{s}]", .{handler_key});
        return MyError.BadRequest;
    };

    return handler(postfix, message_allocator);
}

/// Get the absolute path to the given file in the current working directory
/// The returned string is null-terminated
/// The caller must free the returned pointer
pub fn getAbsoluteLocalFilePath(file_name: []const u8, allocator: std.mem.Allocator) MyError![]const u8 {
    const cwd = std.process.getCwdAlloc(allocator) catch
        return MyError.System;
    defer allocator.free(cwd);

    const a = 0;
    const b = cwd.len;
    const c = b + 1 + file_name.len; // + "/" + "file_name"
    const total_len: usize = c + 1; // + "\x00"

    const abs_path_s: []u8 = allocator.alloc(u8, total_len) catch
        return MyError.MemoryAllocation;
    const abs_path_p: [*]u8 = @ptrCast(abs_path_s);

    std.mem.copyForwards(u8, abs_path_p[a..b], cwd);
    std.mem.copyForwards(u8, abs_path_p[b..c], "/" + file_name);
    abs_path_p[c] = 0;

    return abs_path_p[0..total_len];
}

test "demo getAbsoluteLocalFilePath" {
    try std.process.changeCurDir("/tmp"); // /private/tmp
    const abs_path = try getAbsoluteLocalFilePath("test", std.testing.allocator);
    defer std.testing.allocator.free(abs_path);

    std.debug.print("Absolute file path: {s}\n", .{abs_path});
}
