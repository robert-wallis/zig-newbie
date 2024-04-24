const std = @import("std");

// ❌ Fails
//    % zig-0.12.0 test example_e.zig -freference-trace                                                                                                                                                                                              (main)
//    example_e.zig:5:26: error: expected type '[]u8', found '*const [8]u8'
//        const actual: []u8 = &std.fmt.bytesToHex(input, .lower);
//                             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//    example_e.zig:5:26: note: cast discards const qualifier
test "bytesToHex" {
    const input = "\xde\xad\xc0\xde";
    const actual: []u8 = &std.fmt.bytesToHex(input, .lower);
    try std.testing.expectEqualStrings("deadc0de", &actual);
}
