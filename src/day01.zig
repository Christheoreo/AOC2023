const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");
const testData = @embedFile("data/day01.test.txt");
const testData2 = @embedFile("data/day01.test2.txt");
const namesWhitelist = [9][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
const digitsWhitelist = [10]u8{ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };

const NotFoundError = error{ NotFound, Unknown };

pub fn main() !void {
    const startTime = std.time.nanoTimestamp();
    // const sum = try solvePartOne(data);
    const sum = try solvePartTwo(data);
    const elapsedTime = std.time.nanoTimestamp() - startTime;
    std.debug.print("Function execution time: {} nanoseconds\n", .{elapsedTime});

    std.debug.print("Answer is {}\n", .{sum});
}

fn whitelistContainsValue(target: u8) bool {
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

fn whitelistWordsContainsValue(target: []u8) bool {
    // 0-9 decimal UTF-8 byte values
    var found = false;
    for (namesWhitelist) |element| {
        if (std.mem.eql([]u8, target, element)) {
            found = true;
            break;
        }
    }
    return found;
}

fn getValueOfName(name: []u8) !u32 {
    for (namesWhitelist, 0..) |element, index| {
        if (std.mem.eql([]u8, name, element)) {
            return index + 1;
        }
    }
    return NotFoundError.NotFound;
}

pub fn solvePartOne(buffer: []const u8) !u32 {
    var sum: u32 = 0;
    var lines = std.mem.split(u8, buffer, "\n");
    while (lines.next()) |line| {
        var index: usize = 0;

        var a: u32 = 0;
        var b: u32 = 0;
        // lets find out how many numbers there are.
        while (index < line.len) : (index += 1) {
            if (whitelistContainsValue(line[index])) {
                const x = [1]u8{line[index]};
                if (a == 0) {
                    a = try std.fmt.parseInt(u32, &x, 10);
                    continue;
                }
                b = try std.fmt.parseInt(u32, &x, 10);
            }
        }
        switch (b == 0) {
            true => {
                a *= 11;
            },
            false => {
                a *= 10;
            },
        }

        sum += (a + b);
    }

    return sum;
}

pub fn solvePartTwo(buffer: []const u8) !u32 {
    // std.debug.print("{s}\n", .{buffer});
    var lines = std.mem.split(u8, buffer, "\n");
    var sum: u32 = 0;
    while (lines.next()) |line| {
        // starting at index 0 , check for a digit
        // if its not a digit, check if the byte matches the start of a number name E.g. o for one, or t for two,three
        // if its a match for any, check for potential sub strings.
        // if its a match - save it
        // then start the same process but from the back
        var index: usize = 0;
        var a: u32 = 0;
        var aIndex: usize = 0;
        var b: u32 = 0;

        while (index < line.len) : (index += 1) {
            if (whitelistContainsValue(line[index])) {
                const x = [1]u8{line[index]};
                a = try std.fmt.parseInt(u32, &x, 10);
                aIndex = index;
                break;
            }

            for (namesWhitelist, 0..) |name, nameIndex| {
                if (index + name.len > line.len - 1) continue;
                const memory = line[index .. index + name.len];

                if (std.mem.eql(u8, memory, name)) {
                    var x: u32 = @intCast(nameIndex);
                    a = x + 1;

                    aIndex = index;
                    break;
                }
            }

            if (a != 0) {
                break;
            }
        }

        index = line.len - 1;
        while (index >= aIndex) : (index -= 1) {
            if (whitelistContainsValue(line[index])) {
                const x = [1]u8{line[index]};
                b = try std.fmt.parseInt(u32, &x, 10);
                break;
            }

            for (namesWhitelist, 0..) |name, nameIndex| {
                if (index < name.len) continue;
                const memory = line[(index - (name.len - 1)) .. index + 1];
                if (std.mem.eql(u8, memory, name)) {
                    var x: u32 = @intCast(nameIndex);
                    b = x + 1;
                    break;
                }
            }

            if (b != 0) {
                break;
            }
        }
        switch (b == 0) {
            true => {
                a *= 11;
            },
            false => {
                a *= 10;
            },
        }

        sum += (a + b);
    }
    return sum;
}
test "expect solvePart 1 to work" {
    try std.testing.expect(try solvePartOne(testData) == 142);
}

test "expect solvePartTwo to work" {
    try std.testing.expect(try solvePartTwo(testData2) == 281);
}
