const std = @import("std");

const mymessage = @import("mymessage");

pub fn main() u8 {
    mymessage.init() catch |err| {
        std.log.err("Error initializing mymessage\n{!}", .{err});
        return @truncate(@intFromError(err));
    };
    defer mymessage.deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check: std.heap.Check = gpa.deinit();
        if (check == std.heap.Check.leak) {
            std.log.err("Memory leak detected", .{});
        }
    }
    const allocator = gpa.allocator();

    var arg_iterator = std.process.argsWithAllocator(allocator) catch {
        std.log.err("Failed to initialize ArgIterator", .{});
        return @truncate(@intFromError(mymessage.MyError.Initialization));
    };
    defer arg_iterator.deinit();

    // Initialize arguments with an ordering constraint
    var args: [2]([:0]const u8) = undefined;
    var i: u8 = 0;
    _ = arg_iterator.next(); // Ignore the 0th argument (program invocation)
    while (arg_iterator.next()) |arg| : (i += 1) {
        std.log.debug("Program argument: {s}", .{arg});
        args[i] = arg;
    }
    if (i != 2) {
        std.log.err("Program must be invoked with exactly two positional arguments.", .{});
        return 1;
    }

    const handler_key = args[0];
    const postfix = args[1];
    const message: []const u8 = mymessage.getMessage(
        handler_key,
        postfix,
    ) catch |err| {
        std.log.err(
            \\Error retrieving message: {!}
            \\    handler_key: {s}
        , .{ err, handler_key });
        // @intFromError returns a u16
        return @truncate(@intFromError(err));
    };

    _ = std.io.getStdOut().write(message) catch |err| {
        std.log.err("Error writing to standard output. {!}", .{err});
        return 1;
    };
    return 0;
}
