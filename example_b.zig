const std = @import("std");

fn twice(input: []const u8) [input.len * 2]u8 {
    var output: [input.len * 2]u8 = undefined;
    for (input, 0..input.len) |c, i| {
        output[i] = c;
        output[input.len + i] = c;
    }
    return output;
}

test twice {
    const input = "pizza";
    const actual: [input.len * 2]u8 = twice(input);
    try std.testing.expectEqualStrings("pizzapizza", &actual);
}
