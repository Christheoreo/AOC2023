const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
const testData = @embedFile("data/day08.test.txt");
const testData2 = @embedFile("data/day08.test2.txt");
const testData3 = @embedFile("data/day08.test3.txt");

const MapDetail = struct { location: [3]u8, left: [3]u8, right: [3]u8 };
pub fn main() !void {
    var startTimePart = std.time.nanoTimestamp();
    var partOneAnswer = try solvePartOne(data);
    var elapsedTimePart: i128 = std.time.nanoTimestamp() - startTimePart;
    const oneMil: f128 = 1_000_000;
    var floatingPoint: f128 = @floatFromInt(elapsedTimePart);
    var mili: f128 = floatingPoint / oneMil;
    std.debug.print("Part 1 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    std.debug.print("Answer to part one is {}\n", .{partOneAnswer});

    startTimePart = std.time.nanoTimestamp();
    const partTwoAnswer = try solvePartTwo(data);
    elapsedTimePart = std.time.nanoTimestamp() - startTimePart;

    floatingPoint = @floatFromInt(elapsedTimePart);
    mili = floatingPoint / oneMil;
    std.debug.print("Part 2 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    std.debug.print("Answer to part two is {}\n", .{partTwoAnswer});
}

pub fn solvePartOne(buffer: []const u8) !u32 {
    var answer: u32 = 0;
    var lines = std.mem.splitAny(u8, buffer, "\n");
    var lineIndex: usize = 0;
    var allocator = std.heap.page_allocator;
    var instructions = std.ArrayList(u8).init(allocator);
    defer instructions.deinit();
    var maps = std.ArrayList(MapDetail).init(allocator);
    defer maps.deinit();

    var detailsMap = std.AutoHashMap([3]u8, MapDetail).init(allocator);
    defer detailsMap.deinit();

    while (lines.next()) |line| {
        defer lineIndex += 1;
        if (lineIndex == 0) {
            var i: usize = 0;
            while (i < line.len) : (i += 1) {
                try instructions.append(line[i]);
            }
            continue;
        }
        if (lineIndex == 1) continue;
        const detail = MapDetail{ .location = [3]u8{ line[0], line[1], line[2] }, .left = [3]u8{ line[7], line[8], line[9] }, .right = [3]u8{ line[12], line[13], line[14] } };

        try detailsMap.put([3]u8{ line[0], line[1], line[2] }, detail);
        try maps.append(detail);
    }

    const instructionsArray = instructions.items;
    var instructionIndex: u32 = 0;

    var currentDetail: MapDetail = detailsMap.get([3]u8{ 'A', 'A', 'A' }).?;
    while (!std.mem.eql(u8, &currentDetail.location, &[3]u8{ 'Z', 'Z', 'Z' })) {
        defer answer += 1;
        if (instructionsArray[instructionIndex] == 'L') {
            currentDetail = detailsMap.get(currentDetail.left).?;
        } else {
            currentDetail = detailsMap.get(currentDetail.right).?;
        }
        if (instructionIndex + 1 >= instructionsArray.len) {
            instructionIndex = 0;
        } else instructionIndex += 1;
    }
    return answer;
}

pub fn solvePartTwo(buffer: []const u8) !u128 {
    var answer: u128 = 0;
    var lines = std.mem.splitAny(u8, buffer, "\n");
    var lineIndex: usize = 0;
    var allocator = std.heap.page_allocator;
    var instructions = std.ArrayList(u8).init(allocator);
    defer instructions.deinit();
    var maps = std.ArrayList(MapDetail).init(allocator);
    defer maps.deinit();

    var detailsMap = std.AutoHashMap([3]u8, MapDetail).init(allocator);
    defer detailsMap.deinit();

    var currentDetails = std.ArrayList(MapDetail).init(allocator);
    defer currentDetails.deinit();

    while (lines.next()) |line| {
        defer lineIndex += 1;
        if (lineIndex == 0) {
            var i: usize = 0;
            while (i < line.len) : (i += 1) {
                try instructions.append(line[i]);
            }
            continue;
        }
        if (lineIndex == 1) continue;
        const detail = MapDetail{ .location = [3]u8{ line[0], line[1], line[2] }, .left = [3]u8{ line[7], line[8], line[9] }, .right = [3]u8{ line[12], line[13], line[14] } };

        try detailsMap.put([3]u8{ line[0], line[1], line[2] }, detail);
        if (line[2] == 'A') {
            try currentDetails.append(detail);
        }
        try maps.append(detail);
    }

    const instructionsArray = instructions.items;
    var instructionIndex: u32 = 0;

    var dm = try allocator.alloc(u128, currentDetails.items.len);

    defer allocator.free(dm);

    var i: u32 = 0;
    while (i < dm.len) : (i += 1) {
        dm[i] = 0;
    }
    while (true) {
        answer += 1;
        var detailsIndex: u32 = 0;
        while (detailsIndex < currentDetails.items.len) : (detailsIndex += 1) {
            if (instructionsArray[instructionIndex] == 'L') {
                currentDetails.items[detailsIndex] = detailsMap.get(currentDetails.items[detailsIndex].left).?;
            } else {
                currentDetails.items[detailsIndex] = detailsMap.get(currentDetails.items[detailsIndex].right).?;
            }

            if (currentDetails.items[detailsIndex].location[2] == 'Z') {
                if (dm[detailsIndex] == 0) {
                    dm[detailsIndex] = answer;
                }
            }
        }

        var allZeros: bool = false;
        for (dm) |xx| {
            if (xx == 0) {
                allZeros = true;
                break;
            }
        }

        if (!allZeros) break;

        if (instructionIndex + 1 >= instructionsArray.len) {
            instructionIndex = 0;
        } else instructionIndex += 1;
    }

    answer = findLcm(dm);

    return answer;
}

// Greatest Common Divider
fn gcd(a: u128, b: u128) u128 {
    var aa: u128 = a;
    var bb: u128 = b;
    while (bb != 0) {
        const temp = bb;
        bb = aa % bb;
        aa = temp;
    }
    return aa;
}

// Least common multiple
fn lcm(a: u128, b: u128) u128 {
    if (a == 0 or b == 0) {
        return 0;
    }
    return a * b / gcd(a, b);
}

fn findLcm(numbers: []u128) u128 {
    var result = numbers[0];
    var i: usize = 1;
    while (i < numbers.len) : (i += 1) {
        result = lcm(result, numbers[i]);
    }
    return result;
}

test "part one should solve" {
    try std.testing.expect(try solvePartOne(testData) == 2);
}

test "part two should solve" {
    try std.testing.expect(try solvePartTwo(testData3) == 6);
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
