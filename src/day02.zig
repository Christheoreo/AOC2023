const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");
const testData = @embedFile("data/day02.test.txt");

pub fn main() !void {
    var startTimePart = std.time.nanoTimestamp();
    const partOneAnswer = try solvePartOne(data);
    var elapsedTimePart = std.time.nanoTimestamp() - startTimePart;
    std.debug.print("Part 1 took: {} nanoseconds\n", .{elapsedTimePart});
    std.debug.print("Answer to part 1 = {}\n", .{partOneAnswer});

    startTimePart = std.time.nanoTimestamp();
    const partTwoAnswer = try solvePartTwo(data);
    elapsedTimePart = std.time.nanoTimestamp() - startTimePart;
    std.debug.print("Part 2 took: {} nanoseconds\n", .{elapsedTimePart});
    std.debug.print("Answer to part 2 = {}\n", .{partTwoAnswer});
}

pub fn solvePartOne(buffer: []const u8) !u32 {
    var sum: u32 = 0;
    var lines = std.mem.split(u8, buffer, "\n");
    var id: u32 = 0;
    while (lines.next()) |line| {
        id += 1;
        var indexOfStart = std.mem.indexOfAny(u8, line, ":");
        var indexA: u32 = @intCast(indexOfStart.?);

        const setData = line[indexA + 2 ..];

        var sets = std.mem.splitAny(u8, setData, ";");
        var shouldAdd: bool = true;
        while (sets.next()) |set| {
            var red: u32 = 0;
            var blue: u32 = 0;
            var green: u32 = 0;

            var setWithoutSpace = std.mem.trim(u8, set, " ");
            var rawPairs = std.mem.splitAny(u8, setWithoutSpace, ",");
            while (rawPairs.next()) |rawPair| {
                var trimmedRawPair = std.mem.trim(u8, rawPair, " ");
                var pair = std.mem.splitAny(u8, trimmedRawPair, " ");

                var value = try parseInt(u8, pair.next().?, 10);
                var colour = pair.next().?;

                if (std.mem.eql(u8, colour, "red")) {
                    red += value;
                } else if (std.mem.eql(u8, colour, "blue")) {
                    blue += value;
                } else if (std.mem.eql(u8, colour, "green")) {
                    green += value;
                }
            }

            if (red > 12 or green > 13 or blue > 14) {
                shouldAdd = false;
                break;
            }
        }
        if (shouldAdd) {
            sum += id;
        }
    }
    return sum;
}

pub fn solvePartTwo(buffer: []const u8) !u32 {
    var sum: u32 = 0;
    var lines = std.mem.split(u8, buffer, "\n");
    var id: u32 = 0;
    while (lines.next()) |line| {
        id += 1;
        var indexOfStart = std.mem.indexOfAny(u8, line, ":");
        var indexA: u32 = @intCast(indexOfStart.?);

        const setData = line[indexA + 2 ..];

        var sets = std.mem.splitAny(u8, setData, ";");
        var red: u32 = 0;
        var blue: u32 = 0;
        var green: u32 = 0;
        while (sets.next()) |set| {
            var setWithoutSpace = std.mem.trim(u8, set, " ");
            var rawPairs = std.mem.splitAny(u8, setWithoutSpace, ",");
            while (rawPairs.next()) |rawPair| {
                var trimmedRawPair = std.mem.trim(u8, rawPair, " ");
                var pair = std.mem.splitAny(u8, trimmedRawPair, " ");

                var value = try parseInt(u8, pair.next().?, 10);
                var colour = pair.next().?;

                if (std.mem.eql(u8, colour, "red")) {
                    if (value > red) {
                        red = value;
                    }
                } else if (std.mem.eql(u8, colour, "blue")) {
                    if (value > blue) {
                        blue = value;
                    }
                } else if (std.mem.eql(u8, colour, "green")) {
                    if (value > green) {
                        green = value;
                    }
                }
            }
        }
        //

        sum += (red * green * blue);
    }
    return sum;
}

test "Make sure part 1 works with test data" {
    try std.testing.expect(try solvePartOne(testData) == 8);
}

test "Make sure part 2 works with test data" {
    try std.testing.expect(try solvePartTwo(testData) == 2286);
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
