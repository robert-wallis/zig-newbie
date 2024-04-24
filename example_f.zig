const std = @import("std");

// ❌ Fails
//    % zig-0.12.0 test example_f.zig -freference-trace                                                                                                                                                                                                            (main)
//    example_f.zig:5:39: error: expected type '[8]u8', found pointer
//        const actual: [input.len * 2]u8 = &std.fmt.bytesToHex(input, .lower);
//                                          ^
//    example_f.zig:5:39: note: address-of operator always returns a pointer
test "bytesToHex" {
    const input = "\xde\xad\xc0\xde";
    const actual: [input.len * 2]u8 = &std.fmt.bytesToHex(input, .lower);
    try std.testing.expectEqualStrings("deadc0de", &actual);
}
