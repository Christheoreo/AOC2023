const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");
const testData = @embedFile("data/day04.test.txt");

pub fn main() !void {
    var startTimePart = std.time.nanoTimestamp();
    // var partOneAnswer = try solvePartOne(testData);
    var partOneAnswer = try solvePartOne(data);
    var elapsedTimePart: i128 = std.time.nanoTimestamp() - startTimePart;
    const oneMil: f128 = 1_000_000;
    var floatingPoint: f128 = @floatFromInt(elapsedTimePart);
    const mili: f128 = floatingPoint / oneMil;
    std.debug.print("Part 1 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });

    std.debug.print("Answer to part one is {}\n", .{partOneAnswer});
}

pub fn solvePartOne(buffer: []const u8) !u32 {
    var answer: u32 = 0;
    var lines = std.mem.split(u8, buffer, "\n");
    var lineIndex: u16 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;
        // std.debug.print("Line = {s}\n", .{line});
        const colon = [1]u8{':'};
        const indexOfColon = std.mem.indexOfAny(u8, line, &colon).?;
        var content = line[indexOfColon..];
        const splitter = [1]u8{'|'};
        const space = [1]u8{' '};

        const indexOfSplitter = std.mem.indexOfAny(u8, content, &splitter).?;

        var winningNumbers = content[2 .. indexOfSplitter - 1];
        winningNumbers = std.mem.trim(u8, winningNumbers, &space);
        var yourNumbers = content[indexOfSplitter + 2 ..];
        var winningCharsIterator = split(u8, winningNumbers, &space);
        // var yourChars = split(u8, yourNumbers, &space).buffer;
        const replacement = [1]u8{'.'};
        // Allocator.alloc(self: Allocator, comptime T: type, n: usize)
        var allocator = std.heap.page_allocator;
        var size = std.mem.replacementSize(u8, yourNumbers, &space, &replacement);
        const yourCharsAllocator = try allocator.alloc(u8, size);
        _ = std.mem.replace(u8, yourNumbers, &space, &replacement, yourCharsAllocator);
        // std.debug.print("xxx is:{any}\n", .{yourCharsAllocator});
        var sum: u32 = 0;
        while (winningCharsIterator.next()) |digitsAsBytes| {
            // std.debug.print("Bytes {s}\n", .{digitsAsBytes});
            // const valueToFind = [_]u8{ digitsAsBytes };
            // if (indexOfAny(u8, yourCharsAllocator, digitsAsBytes)) |_| {
            if (inArray(yourNumbers, digitsAsBytes)) {
                std.debug.print("Found {s}!\n", .{digitsAsBytes});
                switch (sum) {
                    0 => {
                        sum = 1;
                    },
                    else => {
                        sum *= 2;
                    },
                }
            }
        }

        answer += sum;

        // std.debug.print("Index is as {}\n", .{indexOfColon});
        // std.debug.print("Winning is:{s}\n", .{winningNumbers});
        // std.debug.print("Yours is:{s}\n", .{yourNumbers});
    }
    //
    return answer;
}
fn inArray(haystack: []const u8, needle: []const u8) bool {
    const needleLength: usize = needle.len;
    var index: usize = 0;

    while (index + needleLength <= haystack.len) : (index += 1) {
        if (std.mem.eql(u8, needle, haystack[index .. index + needleLength])) {
            return true;
        }
    }

    return false;
}
// fn indexOfAnyX(comptime T: type, haystack: []const T, needle: []const T) ?usize {
//     if (needle.len == 0) {
//         return null; // or an error code, depending on your needs
//     }

//     var index: usize = 0;

//     while (index < haystack.len) : (index += 1) {
//         const x = [1]u8{haystack[index]};
//         if (index + needle.len <= haystack.len and std.mem.eql(u8, &x, needle)) {
//             return index;
//         }
//     }

//     return null; // or an error code, depending on your needs
// }
// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
