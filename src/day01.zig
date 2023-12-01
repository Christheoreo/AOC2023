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

pub fn main() !void {
    const startTime = std.time.nanoTimestamp();
    const sum = try solvePartOne(data);
    const elapsedTime = std.time.nanoTimestamp() - startTime;
    std.debug.print("Function execution time: {} nanoseconds\n", .{elapsedTime});

    std.debug.print("Answer is {}\n", .{sum});
}

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

test "expect solvePart 1 to work" {
    try std.testing.expect(try solvePartOne(testData) == 142);
}
