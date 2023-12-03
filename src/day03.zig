const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");
const testData = @embedFile("data/day03.test.txt");
const digitsWhitelist = [10]u8{ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };
const fullStop: u8 = 46;
const fullStopArr = [1]u8{46};

pub fn main() !void {
    // const partOneAnswer = try solvePartOne(testData);
    const partOneAnswer = try solvePartOne(data);

    std.debug.print("Answer to part one is {}\n", .{partOneAnswer});
}

fn solvePartOne(buffer: []const u8) !u32 {
    const allocator = std.heap.page_allocator;
    var list = std.ArrayList(@Vector(2, u32)).init(allocator);
    defer list.deinit();
    // var symbolLocations: []@Vector(2, u32) = undefined;
    var lines = std.mem.split(u8, buffer, "\n");
    var sum: u32 = 0;
    var lineIndex: u32 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;
        var byteIndex: u32 = 0;
        while (byteIndex < line.len) : (byteIndex += 1) {
            // const char = [1]u8{line[byteIndex]};
            // if (std.mem.eql(u8, &char, &fullStopArr)) {
            const char: u8 = line[byteIndex];
            if (char != fullStop and !byteIsANumber(char)) {
                const newValue: @Vector(2, u32) = .{ lineIndex, byteIndex };
                try list.append(newValue);
            }
        }
    }

    lines = std.mem.split(u8, buffer, "\n");

    // std.debug.print("items {any}", .{list.items});
    lineIndex = 0;
    while (lines.next()) |line| {
        // std.debug.print("Line {s}\n", .{line});
        defer lineIndex += 1;
        var byteIndex: u32 = 0;
        while (byteIndex < line.len) {
            var char: u8 = line[byteIndex];
            var number: u32 = 0;
            var isGood: bool = false;
            if (byteIsANumber(char)) {
                if (byteIndex + 1 >= line.len) {
                    // this is it
                    const x = [1]u8{char};
                    number = try parseInt(u32, &x, 10);
                    byteIndex += 1;
                } else {
                    // now check if the byte next to it is a number
                    var localByteIndex: u32 = byteIndex + 1;
                    var numbersAsBytes = std.ArrayList(u8).init(allocator);
                    defer numbersAsBytes.deinit();
                    try numbersAsBytes.append(line[byteIndex]);
                    if (numberHasAdjacentSymbol(.{ lineIndex, byteIndex }, list.items)) {
                        isGood = true;
                    }
                    while (localByteIndex < line.len) : (localByteIndex += 1) {
                        if (!byteIsANumber(line[localByteIndex])) {
                            break;
                        }
                        try numbersAsBytes.append(line[localByteIndex]);
                        if (!isGood and numberHasAdjacentSymbol(.{ lineIndex, localByteIndex }, list.items)) {
                            isGood = true;
                        }
                    }

                    number = try parseInt(u32, numbersAsBytes.items, 10);
                    byteIndex = localByteIndex;
                }
                // std.debug.print("Number = {}\n", .{number});
            } else {
                byteIndex += 1;
            }

            if (isGood) {
                sum += number;
                std.debug.print("Number {} is good!\n", .{number});
            }
        }
    }

    return sum;
}

fn byteIsANumber(target: u8) bool {
    // 0-9 decimal UTF-8 byte values
    var found = false;
    for (digitsWhitelist) |element| {
        if (element == target) {
            found = true;
            break;
        }
    }
    return found;
}

fn numberHasAdjacentSymbol(vec: @Vector(2, u32), symbols: []@Vector(2, u32)) bool {
    for (symbols) |element| {
        // std.debug.print("element = {any} and vec = {}\n", .{ element, vec });
        // if (element[0] == vec[0] and element[1] == vec[1]) {
        //     return true;
        // }

        if (vec[0] > 0) {
            // Directly above
            if (element[0] == vec[0] - 1 and element[1] == vec[1]) {
                return true;
            }
            if (vec[1] > 0) {
                // above and left
                if (element[0] == vec[0] - 1 and element[1] == vec[1] - 1) {
                    return true;
                }
            }

            // above and right
            if (element[0] == vec[0] - 1 and element[1] == vec[1] + 1) {
                return true;
            }
        }

        // directly below
        if (element[0] == vec[0] + 1 and element[1] == vec[1]) {
            return true;
        }
        if (vec[1] > 0) {
            // below and left
            if (element[0] == vec[0] + 1 and element[1] == vec[1] - 1) {
                return true;
            }

            // below and right
            if (element[0] == vec[0] + 1 and element[1] == vec[1] + 1) {
                return true;
            }
        }
        // left
        if (vec[1] > 0) {
            // left
            if (element[0] == vec[0] and element[1] == vec[1] - 1) {
                return true;
            }

            // right
            if (element[0] == vec[0] and element[1] == vec[1] + 1) {
                return true;
            }
        }
    }
    return false;
}

test "part 1 should solve" {
    try std.testing.expect(try solvePartOne(testData) == 4361);
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
