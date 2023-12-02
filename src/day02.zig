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

const Colours = enum { blue, green, red };

const Pair = struct { colour: Colours, value: u32 };

const Set = struct { pairs: []Pair };

pub fn main() !void {
    // const partOneAnswer = try solvePartOne(testData);
    const partOneAnswer = try solvePartOne(data);

    std.debug.print("Answer to part 1 = {}\n", .{partOneAnswer});
}

pub fn solvePartOne(buffer: []const u8) !u32 {
    var sum: u32 = 0;
    var lines = std.mem.split(u8, buffer, "\n");
    var id: u32 = 0;
    while (lines.next()) |line| {
        id += 1;
        // const buf = [1]u8{line[5]};
        // const id = try parseInt(u32, &buf, 10);
        // std.debug.print("ID = {}\n", .{id});
        // const abc = [1]u8{":"};
        // _ = abc;
        var indexOfStart = std.mem.indexOfAny(u8, line, ":");
        var indexA: u32 = @intCast(indexOfStart.?);
        // std.debug.print("xx = {}\n", .{indexA});
        // if (id < 10) {
        //     continue;
        // }
        const setData = line[indexA + 2 ..];
        // std.debug.print("set data = {s}\n", .{setData});
        var sets = std.mem.splitAny(u8, setData, ";");
        var shouldAdd: bool = true;
        while (sets.next()) |set| {
            var red: u32 = 0;
            var blue: u32 = 0;
            var green: u32 = 0;

            var setWithoutSpace = std.mem.trim(u8, set, " ");
            // std.debug.print("Set = {s}\n", .{setWithoutSpace});
            var rawPairs = std.mem.splitAny(u8, setWithoutSpace, ",");
            while (rawPairs.next()) |rawPair| {
                var trimmedRawPair = std.mem.trim(u8, rawPair, " ");
                var pair = std.mem.splitAny(u8, trimmedRawPair, " ");

                // std.debug.print("Pair = {s}\n", .{value});
                var value = try parseInt(u8, pair.next().?, 10);
                var colour = pair.next().?;

                // if (colour == Colours.red) {
                //     red += value;
                // } else if (colour == Colours.blue) {
                //     blue += value;
                // } else if (colour == Colours.green) {
                //     green += value;
                // }
                if (std.mem.eql(u8, colour, "red")) {
                    red += value;
                } else if (std.mem.eql(u8, colour, "blue")) {
                    blue += value;
                } else if (std.mem.eql(u8, colour, "green")) {
                    green += value;
                }
                // std.debug.print("Value = {}\n", .{value});
            }

            // if (red <= 12 and green <= 13 or blue <= 14) {
            //     sum += id;
            // }
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
