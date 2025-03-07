const std = @import("std");

pub const MessageHandler = fn (postfix: []const u8, allocator: std.mem.Allocator) []const u8;

pub fn hello(postfix: []const u8, allocator: std.mem.Allocator) []const u8 {
    return std.fmt.allocPrint(allocator, "Hello {s}\n", .{postfix}) catch |err| {
        reportError(hello, err);
    };
}

pub fn goodbye(postfix: []const u8, allocator: std.mem.Allocator) []const u8 {
    return std.fmt.allocPrint(allocator, "Goodbye {s}\n", .{postfix}) catch |err| {
        reportError(goodbye, err);
    };
}

fn reportError(handler: MessageHandler, err: anyerror) noreturn {
    const handler_name = @typeName(@TypeOf(handler)); // todo: test
    std.log.err("Error invoking message handler [{s}] [{!}]", .{ handler_name, err });
    @panic("Error invoking message handler");
}
