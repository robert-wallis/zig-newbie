const std = @import("std");

// ❌ Fails
//     % zig-0.12.0 test example_d.zig -freference-trace                                                                                                                                                                                              (main)
//     example_d.zig:5:44: error: array literal requires address-of operator (&) to coerce to slice type '[]u8'
//         const actual: []u8 = std.fmt.bytesToHex(input, .lower);
//                              ~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~
test "bytesToHex" {
    const input = "\xde\xad\xc0\xde";
    const actual: []u8 = std.fmt.bytesToHex(input, .lower);
    try std.testing.expectEqualStrings("deadc0de", &actual);
}
