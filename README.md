# Posted to [ziggit.dev](https://ziggit.dev/t/newbie-comptime-anytype-papercuts/4077)

I keep running into papercuts, spend hours fighting the comptime expression checker, instead of hours writing code.  In the following example I won't be changing any logic, just type signatures.

## Example A: ✅

This code works.  It uses an `anytype` and returns `input.len * 2` bytes.  This is a pattern from std.fmt.bytesToHex which I'll bring up in Example D.

```zig
const std = @import("std");

fn twice(input: anytype) [input.len * 2]u8 {
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
```

## Example B: ❌

By just changing `input` from `anytype` to `[]const u8`
```
fn twice(input: []const u8) [input.len * 2]u8
```

I get this error :
```
% zig-0.12.0 test example_b.zig 
example_b.zig:3:35: error: unable to evaluate comptime expression
fn twice(input: []const u8) [input.len * 2]u8 {
                             ~~~~~^~~~
referenced by:
    decltest.twice: example_b.zig:14:39
```

When I read that error, not knowing about the `anytype` hack, I was confused why the Standard Library can use a comptime expression for the return value, but I am not allowed.  

## Example C: ✅
Changing the signature to add `comptime` with `[]const u8` works:
```
fn twice(comptime input: []const u8) [input.len * 2]u8
```
And that makes sense logically, the error says `input.len` is a **comptime** expression so it makes sense to force input to be comptime.

But the original `anytype` version Example A, doesn't indicate it's a comptime function.  

I as a newbie, don't want it to be comptime because that means *to me* that it won't work for dynamic strings, and it's only working now because it's in a comptime test.

## Example D: ❌
Let's start over, and use a function I can't change.
`std.fmt.`[`bytesToHex`][1] has the following signature:
```
pub fn bytesToHex(input: anytype, case: Case) [input.len * 2]u8
```
So to use it I started by asking for a slice of `[]u8` which won't compile.
```
const std = @import("std");

test "bytesToHex" {
    const input = "\xde\xad\xc0\xde";
    const actual: []u8 = std.fmt.bytesToHex(input, .lower);
    try std.testing.expectEqualStrings("deadc0de", &actual);
}
```
```
example_d.zig:5:44: error: array literal requires address-of operator (&) to coerce to slice type '[]u8'
    const actual: []u8 = std.fmt.bytesToHex(input, .lower);
```
You probably already knew it was an array and I was asking for a slice. I as a newbie haven't burned that into my brain yet.

## Example E: ❌
Sure I'll coerce it, no big deal.

```
% zig-0.12.0 test example_e.zig
example_e.zig:5:26: error: expected type '[]u8', found '*const [8]u8'
    const actual: []u8 = &std.fmt.bytesToHex(input, .lower);
                         ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
example_e.zig:5:26: note: cast discards const qualifier
```

## Example F: ❌
I see an [8] in the length, so it has a `const`ant length. 
`bytesToHex` returns an array of double length. I can do that too.
Just adding `[input.len * 2]` to change `actual` into an array should work:

```
example_f.zig:5:39: error: expected type '[8]u8', found pointer
    const actual: [input.len * 2]u8 = &std.fmt.bytesToHex(input, .lower);
                                      ^
example_f.zig:5:39: note: address-of operator always returns a pointer
```
Yeah, the '`&`' in there because zig wanted me to use the "address of operator(&) to coerce to slice".

## Example G ✅
Got it, `actual` is an array now not a slice.
```
const std = @import("std");

test "bytesToHex" {
    const input = "\xde\xad\xc0\xde";
    const actual: [input.len * 2]u8 = std.fmt.bytesToHex(input, .lower);
    try std.testing.expectEqualStrings("deadc0de", &actual);
}
```

## Example H ✅
But the sad part is I could have avoided all that by just not specifying the type.
```
const std = @import("std");

test "bytesToHex" {
    const input = "\xde\xad\xc0\xde";
    const actual = std.fmt.bytesToHex(input, .lower);
    try std.testing.expectEqualStrings("deadc0de", &actual);
}
```

## Back and Forth
What it feels like to be a zig user, is going back and forth with the compiler trying to implement its suggestions but finding another error.

It sounds good to have a language that doesn't hide allocations. But sometimes it does hide stack allocations at comptime. bytesToHex is doubling the memory used by `input`.

I've only been using the language for about two weeks.  But I find myself writing code in another language to get the logic figured out. And then 2x to 10x more time translating that to zig.  Dev time is valuable, sometimes it's more expensive than runtime.

## Solutions?

What do you think the solutions are? It's a 'skill issue' on my part, but can something be done to help bring engineer's skill up?

* I read this documentation on [type coercion slices, arrays and pointers](https://ziglang.org/documentation/0.12.0/#toc-Type-Coercion-Slices-Arrays-and-Pointers) but when actually coding like above, I am somehow often iterating trying to get it to compile
* Is not specifying a type a good shortcut to writing code faster that compiles?
* Should the array literal coerce error not activate for `const` qualified arrays?

[1]: https://ziglang.org/documentation/0.12.0/std/#std.fmt.bytesToHex "std.fmt.bytesToHex"