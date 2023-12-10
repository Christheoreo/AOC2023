const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");
const testData = @embedFile("data/day09.test.txt");

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

pub fn solvePartOne(buffer: []const u8) !i32 {
    var lines = std.mem.splitAny(u8, buffer, "\n");
    var lineIndex: usize = 0;
    var allocator = std.heap.page_allocator;
    var answer: i32 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;
        var numbersSplit = std.mem.splitAny(u8, line, " ");
        var numbers = std.ArrayList(i32).init(allocator);
        defer numbers.deinit();
        while (numbersSplit.next()) |numStr| {
            try numbers.append(try parseInt(i32, numStr, 10));
            // break;
        }
        answer += try findNextSequence(numbers.items);
    }
    return answer;
}

fn findNextSequence(buffer: []i32) !i32 {
    var allocator = std.heap.page_allocator;
    var sequences = std.ArrayList([]i32).init(allocator);
    defer sequences.deinit();
    var currentBuffer: []i32 = buffer;
    try sequences.append(currentBuffer);

    while (true) {
        var sequence = try allocator.alloc(i32, currentBuffer.len - 1);
        // defer allocator.free(sequence);
        var i: usize = 0;
        var j: usize = 1;
        while (j < currentBuffer.len) {
            std.debug.print("Current buffer length ={} and i = {} and j = {}\n", .{ currentBuffer.len, i, j });
            defer i += 1;
            defer j += 1;
            std.debug.print("a = {} b = {}\n", .{ currentBuffer[j], currentBuffer[i] });
            const diff: i32 = currentBuffer[j] - currentBuffer[i];
            sequence[i] = diff;
        }
        for (sequence) |seq| {
            std.debug.print("val {}\n", .{seq});
        }
        try sequences.append(sequence);
        var allZeros: bool = true;
        for (sequence) |number| {
            if (number != 0) {
                allZeros = false;
                // std.debug.print("fuck\n", .{});
                break;
            }
        }

        // break;

        if (allZeros) break;

        // currentBuffer = sequences.items[sequences.items.len - 1];
        currentBuffer = sequences.getLast();
        std.debug.print("Current buffer now equals {any}\n", .{currentBuffer});
    }

    var sequenceLen: u32 = @intCast(sequences.items.len);
    var sequenceIndex: u32 = 0;
    while (sequenceIndex < sequenceLen) : (sequenceIndex += 1) {
        var currentSequence = sequences.items[sequences.items.len - (1 + sequenceIndex)];
        var lengthOfCurrentSequence: u32 = @intCast(currentSequence.len);
        var newSequence = try allocator.alloc(i32, lengthOfCurrentSequence + 1);
        for (currentSequence, 0..) |seq, index| {
            newSequence[index] = seq;
        }
        // defer allocator.free(newSequence);
        if (sequenceIndex == 0) {
            newSequence[currentSequence.len] = 0;
            continue;
        }

        var sequenceBelow = sequences.items[sequences.items.len - (sequenceIndex)];
        // we want to look BELOW to see what we should be adding...
        const diff = sequenceBelow[sequenceBelow.len - 1];

        newSequence[newSequence.len - 1] = newSequence[newSequence.len - 2] + diff;

        sequences.items[sequenceLen - (1 + sequenceIndex)] = newSequence;
    }

    return sequences.items[0][sequences.items[0].len - 1];
}

pub fn solvePartTwo(buffer: []const u8) !u32 {
    _ = buffer;
    return 0;
}

test "part one should solve" {
    try std.testing.expect(try solvePartOne(testData) == 114);
}

test "part two should solve" {
    try std.testing.expect(try solvePartTwo(testData) == 0);
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
