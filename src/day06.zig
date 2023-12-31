const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");

pub fn main() !void {
    var startTimePart = std.time.nanoTimestamp();
    const times = [_]u32{ 50, 74, 86, 85 };
    const distances = [_]u32{ 242, 1017, 1691, 1252 };
    var partOneAnswer = try solvePartOne(&times, &distances);
    var elapsedTimePart: i128 = std.time.nanoTimestamp() - startTimePart;
    const oneMil: f128 = 1_000_000;
    var floatingPoint: f128 = @floatFromInt(elapsedTimePart);
    var mili: f128 = floatingPoint / oneMil;
    std.debug.print("Part 1 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    std.debug.print("Answer to part one is {}\n", .{partOneAnswer});

    startTimePart = std.time.nanoTimestamp();
    const partTwoAnswer = try solvePartTwo(50748685, 242101716911252);
    elapsedTimePart = std.time.nanoTimestamp() - startTimePart;

    floatingPoint = @floatFromInt(elapsedTimePart);
    mili = floatingPoint / oneMil;
    std.debug.print("Part 2 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    std.debug.print("Answer to part two is {}\n", .{partTwoAnswer});
}

fn solvePartOne(times: []const u32, distances: []const u32) !u64 {
    var answer: u32 = 1;

    for (times, 0..) |time, i| {
        var totalWays: u32 = 0;
        const distanceToBeat = distances[i];
        var miliSecondHold: u32 = 1;
        while (miliSecondHold < time) : (miliSecondHold += 1) {
            const travelTime = time - miliSecondHold;
            const distanceTravelled = travelTime * miliSecondHold;
            if (distanceTravelled > distanceToBeat) {
                totalWays += 1;
            }
        }
        answer *= totalWays;
    }

    return answer;
}

fn solvePartTwo(time: u64, distanceToBeat: u64) !u64 {
    var answer: u32 = 0;
    var miliSecondHold: u32 = 1;
    while (miliSecondHold < time) : (miliSecondHold += 1) {
        const travelTime = time - miliSecondHold;
        const distanceTravelled = travelTime * miliSecondHold;
        if (distanceTravelled > distanceToBeat) {
            answer += 1;
        }
    }

    return answer;
}

test "Part One should solve" {
    const times = [_]u32{ 7, 15, 30 };
    const distances = [_]u32{ 9, 40, 200 };
    try std.testing.expect(try solvePartOne(&times, &distances) == 288);
}

test "Part two should solve" {
    const time: u32 = 71530;
    const distanceToBeat = 940200;
    try std.testing.expect(try solvePartTwo(time, distanceToBeat) == 71503);
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
