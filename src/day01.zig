const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const dataPart1 = @embedFile("data/day01-part1.txt");
const testDataPart1 = @embedFile("data/day01-part1.test.txt");

pub fn main() !void {
    std.debug.print("Hello there {s}\n", .{"Chris!"});
    // var testLines = split(u8, testDataPart1, "\n");
    // _ = testLines;
    try solvePartOne(dataPart1);
    // try solvePartOne(false);
}

// fn arrayContainsValue(comptime T: type, comptime N: usize, S: type) bool {
//     return std.mem.eql(T, N, S);
// }

fn whitelistContainsValue(target: u8) bool {
    // 0-9 decimal UTF-8 byte values
    const whitelist = [10]u8{ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };
    var found = false;
    for (whitelist) |element| {
        if (element == target) {
            found = true;
            break;
        }
    }
    return found;
}

pub fn solvePartOne(buffer: []const u8) !void {
    var sum: u32 = 0;
    var lines = split(u8, buffer, "\n");
    while (lines.next()) |line| {
        var firstIndex: u32 = 0;
        _ = firstIndex;
        var lastIndex = line.len - 1;
        _ = lastIndex;
        var index: usize = 0;
        var numbers: u32 = 0;

        var a: u32 = 0;
        var b: u32 = 0;
        // lets find out how many numbers there are.
        while (index < line.len) : (index += 1) {
            if (whitelistContainsValue(line[index])) {
                const x = [1]u8{line[index]};
                if (a == 0) {
                    a = try parseInt(u32, &x, 10);
                    continue;
                }
                b = try parseInt(u32, &x, 10);
            }
        }

        if (numbers == 1) {
            // find the number
        }
        if (b == 0) {
            a *= 11;
        } else {
            a *= 10;
        }
        std.debug.print("Sum of this line is {}\n", .{a + b});

        sum += (a + b);

        // // first and last arent neccesarily at the beggining and end
        // var a: u32 = 0;
        // var b: u32 = 0;
        // while (firstIndex < lastIndex and lastIndex > firstIndex) {
        //     if (whitelistContainsValue(line[firstIndex])) {
        //         const x = [1]u8{line[firstIndex]};
        //         a = try parseInt(u32, &x, 10);
        //         a = a * 10;
        //     } else {
        //         firstIndex += 1;
        //     }

        //     if (whitelistContainsValue(line[lastIndex])) {
        //         const x = [1]u8{line[lastIndex]};
        //         b = try parseInt(u32, &x, 10);
        //     } else {
        //         lastIndex -= 1;
        //     }

        //     if (a != 0 and b != 0) {
        //         break;
        //     }
        // }

        // if (a == 0) {
        //     b = (b / 10) * 11;
        // }
        // if (b == 0) {
        //     a = (a / 10) * 11;
        // }

        // std.debug.print("Sum of this line is {}\n", .{a + b});
        // sum += (a + b);
    }

    std.debug.print("Answer is {}\n", .{sum});
}

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
