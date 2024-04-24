const std = @import("std");

fn twice(input: []const u8) [input.len * 2]u8 {
    var output: [input.len * 2]u8 = undefined;
    for (input, 0..input.len) |c, i| {
        output[i] = c;
        output[input.len + i] = c;
    }
    return output;
}

// ❌ Fails
//    % zig-0.12.0 test example_b.zig -freference-trace                                                                                                                                                                                              (main)
//    example_b.zig:3:35: error: unable to evaluate comptime expression
//        fn twice(input: []const u8) [input.len * 2]u8 {
//                                     ~~~~~^~~~
//    referenced by:
//    decltest.twice: example_b.zig:21:39
test twice {
    const input = "pizza";
    const actual: [input.len * 2]u8 = twice(input);
    try std.testing.expectEqualStrings("pizzapizza", &actual);
}
