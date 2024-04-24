const std = @import("std");

// ✅ Passes
test "bytesToHex" {
    // Kristoff commented https://ziggit.dev/t/newbie-comptime-anytype-papercuts/4077/2?u=robert-wallis
    // > The slice cases (D, E) didn’t work because []u8 is a mutable slice.
    // > Had you used []const u8 it would have worked.
    // > The slice has to be const because you’re taking a pointer from a temporary value
    // > (the array returned by bytesToHex) and those values are implicitly const.
    const input = "\xde\xad\xc0\xde";
    const actual: []const u8 = &std.fmt.bytesToHex(input, .lower);
    try std.testing.expectEqualStrings("deadc0de", actual);
}
