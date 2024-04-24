const std = @import("std");

// ✅ Passes
test "bytesToHex" {
    const input = "\xde\xad\xc0\xde";
    const actual: [input.len * 2]u8 = std.fmt.bytesToHex(input, .lower);
    try std.testing.expectEqualStrings("deadc0de", &actual);
}
