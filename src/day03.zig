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
const asteriks: u8 = 42;

const Value = struct { startCoOrdinates: @Vector(2, u32), endCoOrdinates: @Vector(2, u32), rawvalue: u32 };

pub fn main() !void {
    var startTimePart = std.time.nanoTimestamp();
    const partOneAnswer = try solvePartOne(data);
    var elapsedTimePart = std.time.nanoTimestamp() - startTimePart;
    std.debug.print("Part 1 took: {} nanoseconds\n", .{elapsedTimePart});

    std.debug.print("Answer to part one is {}\n", .{partOneAnswer});

    startTimePart = std.time.nanoTimestamp();
    const partTwoAnswer = try solvePartTwo(data);
    elapsedTimePart = std.time.nanoTimestamp() - startTimePart;

    std.debug.print("Part 2 took: {} nanoseconds\n", .{elapsedTimePart});
    std.debug.print("Answer to part 2 = {}\n", .{partTwoAnswer});
}

fn solvePartOne(buffer: []const u8) !u32 {
    const allocator = std.heap.page_allocator;
    var list = std.ArrayList(@Vector(2, u32)).init(allocator);
    defer list.deinit();

    var lines = std.mem.split(u8, buffer, "\n");

    var sum: u32 = 0;
    var lineIndex: u32 = 0;

    // Loop through and find all the symbols, and add those at our List to compare later
    while (lines.next()) |line| {
        defer lineIndex += 1;

        var byteIndex: u32 = 0;
        while (byteIndex < line.len) : (byteIndex += 1) {
            const char: u8 = line[byteIndex];
            if (char != fullStop and !byteIsANumber(char)) {
                const newValue: @Vector(2, u32) = .{ lineIndex, byteIndex };
                try list.append(newValue);
            }
        }
    }

    // reset lines.
    lines = std.mem.split(u8, buffer, "\n");
    lineIndex = 0;

    // Loop over lines again
    // Find numbers
    // Clarrify they are next to a symbol from earlier
    // then add the sums
    while (lines.next()) |line| {
        defer lineIndex += 1;

        var byteIndex: u32 = 0;
        while (byteIndex < line.len) {
            var char: u8 = line[byteIndex];
            var number: u32 = 0;
            var isGood: bool = false;

            if (byteIsANumber(char)) {
                // if true, its only one number we are looking at
                // not a single solo number that starts at the end of the line - so not checking thatr situation
                // we need to get the whole number - keep going right until we hit a full stop or a symbol
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
            } else {
                byteIndex += 1;
            }

            if (isGood) {
                sum += number;
            }
        }
    }

    return sum;
}

fn solvePartTwo(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;
    var list = std.ArrayList(@Vector(2, u32)).init(allocator);
    defer list.deinit();

    var numberList = std.ArrayList(Value).init(allocator);
    defer numberList.deinit();

    var lines = std.mem.split(u8, buffer, "\n");

    var sum: u64 = 0;
    var lineIndex: u32 = 0;

    // Loop through and find all the * symbols, and add those at our List to compare later
    while (lines.next()) |line| {
        defer lineIndex += 1;

        var byteIndex: u32 = 0;
        while (byteIndex < line.len) : (byteIndex += 1) {
            const char: u8 = line[byteIndex];
            if (char == asteriks) {
                const newValue: @Vector(2, u32) = .{ lineIndex, byteIndex };
                try list.append(newValue);
            }
        }
    }

    // reset lines.
    lines = std.mem.split(u8, buffer, "\n");
    lineIndex = 0;

    while (lines.next()) |line| {
        defer lineIndex += 1;

        var byteIndex: u32 = 0;
        while (byteIndex < line.len) {
            var char: u8 = line[byteIndex];
            var number: u32 = 0;

            if (byteIsANumber(char)) {

                // we need to get the whole number - keep going right until we hit a full stop or a symbol
                // now check if the byte next to it is a number
                var localByteIndex: u32 = byteIndex + 1;
                var numbersAsBytes = std.ArrayList(u8).init(allocator);
                // var value = Value{ . };
                defer numbersAsBytes.deinit();

                try numbersAsBytes.append(line[byteIndex]);
                var lastFoundIndex: u32 = byteIndex;

                while (localByteIndex < line.len) : (localByteIndex += 1) {
                    if (!byteIsANumber(line[localByteIndex])) {
                        break;
                    }
                    try numbersAsBytes.append(line[localByteIndex]);
                    lastFoundIndex = localByteIndex;
                }

                number = try parseInt(u32, numbersAsBytes.items, 10);
                try numberList.append(Value{ .startCoOrdinates = .{ lineIndex, byteIndex }, .endCoOrdinates = .{ lineIndex, lastFoundIndex }, .rawvalue = number });
                byteIndex = localByteIndex;
            } else {
                byteIndex += 1;
            }
        }

        // now we check to see if any nuymbers match the criteria

    }
    var x: usize = 0;
    while (x < list.items.len) : (x += 1) {
        // so now we need to create a list of potential combinations that we need to check
        var item: @Vector(2, u32) = list.items[x];
        var count: u32 = 0;
        var y: usize = 0;
        var a: u32 = 0;
        var b: u32 = 0;
        while (y < numberList.items.len) : (y += 1) {
            if (count > 2) break;
            var numberValue: Value = numberList.items[y];

            var startCLineIndex: i32 = @intCast(numberValue.startCoOrdinates[0]);
            var symbolLineIndex: i32 = @intCast(item[0]);
            var diff: i32 = startCLineIndex - symbolLineIndex;
            var inReach: bool = false;
            if (diff == 0 or diff == -1 or diff == 1) {
                inReach = true;
            }

            if (!inReach) continue;

            // now we need to see if its inrtage from a horizontal point of view.
            var startCByteIndex: i32 = @intCast(numberValue.startCoOrdinates[1]);
            var inReachHorizontally: bool = false;
            var symbolByteIndex: i32 = @intCast(item[1]);
            while (startCByteIndex <= numberValue.endCoOrdinates[1]) : (startCByteIndex += 1) {
                var horrizontalDiff: i32 = startCByteIndex - symbolByteIndex;

                if (horrizontalDiff == 0 or horrizontalDiff == -1 or horrizontalDiff == 1) {
                    inReachHorizontally = true;
                }
            }

            if (!inReachHorizontally) {
                continue;
            }

            // so here we know that is is in reach, lets set this to a or b and increment the count

            switch (count) {
                0 => {
                    a = numberValue.rawvalue;
                },
                1 => {
                    b = numberValue.rawvalue;
                },
                else => {
                    //
                },
            }
            count += 1;
        }

        if (count != 2) continue;
        sum += a * b;
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
        }
        // right
        if (element[0] == vec[0] and element[1] == vec[1] + 1) {
            return true;
        }
    }
    return false;
}

test "part 1 should solve" {
    try std.testing.expect(try solvePartOne(testData) == 4361);
}

test "part 2 should solve" {
    try std.testing.expect(try solvePartTwo(testData) == 467835);
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
