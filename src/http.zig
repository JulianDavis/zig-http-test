const std = @import("std");

export fn http_get_request(url: [*:0]const u8) callconv(.c) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var body = std.Io.Writer.Allocating.init(allocator);
    defer body.deinit();

    // Convert the C string to a Zig slice
    const slice: []const u8 = std.mem.span(url);
    const uri = std.Uri.parse(slice) catch |err| {
        std.debug.print("Failed to parse uri '{s}': {}\n", .{ slice, err });
        return;
    };

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const response = client.fetch(.{
        .method = .GET,
        .location = .{ .uri = uri },
        .response_writer = &body.writer,
    }) catch |err| {
        std.debug.print("Failed to issue get request: {}\n", .{err});
        return;
    };

    if (response.status != .ok) {
        std.debug.print("Get request failed with HTTP status {d}\n", .{response.status});
        return;
    }
    std.debug.print("{s}\n", .{body.written()});
}
