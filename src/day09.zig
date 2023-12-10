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
        // If i defer the memory, I can't access the arrayList item.
        // defer allocator.free(sequence);
        var i: usize = 0;
        var j: usize = 1;
        while (j < currentBuffer.len) {
            defer i += 1;
            defer j += 1;
            const diff: i32 = currentBuffer[j] - currentBuffer[i];
            sequence[i] = diff;
        }
        try sequences.append(sequence);
        var allZeros: bool = true;
        for (sequence) |number| {
            if (number != 0) {
                allZeros = false;
                break;
            }
        }

        if (allZeros) break;

        currentBuffer = sequences.getLast();
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
        // If i defer the memory, I can't access the arrayList item.
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

pub fn solvePartTwo(buffer: []const u8) !i32 {
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
        answer += try findPrevSequence(numbers.items);
    }
    return answer;
}

fn findPrevSequence(buffer: []i32) !i32 {
    var allocator = std.heap.page_allocator;
    var sequences = std.ArrayList([]i32).init(allocator);
    defer sequences.deinit();
    var currentBuffer: []i32 = buffer;
    try sequences.append(currentBuffer);

    while (true) {
        var sequence = try allocator.alloc(i32, currentBuffer.len - 1);
        // If i defer the memory, I can't access the arrayList item.
        // defer allocator.free(sequence);
        var i: usize = 0;
        var j: usize = 1;
        while (j < currentBuffer.len) {
            defer i += 1;
            defer j += 1;
            const diff: i32 = currentBuffer[j] - currentBuffer[i];
            sequence[i] = diff;
        }
        try sequences.append(sequence);
        var allZeros: bool = true;
        for (sequence) |number| {
            if (number != 0) {
                allZeros = false;
                break;
            }
        }

        if (allZeros) break;
        currentBuffer = sequences.getLast();
    }

    var sequenceLen: u32 = @intCast(sequences.items.len);
    var sequenceIndex: u32 = 0;
    while (sequenceIndex < sequenceLen) : (sequenceIndex += 1) {
        var currentSequence = sequences.items[sequences.items.len - (1 + sequenceIndex)];
        var lengthOfCurrentSequence: u32 = @intCast(currentSequence.len);
        var newSequence = try allocator.alloc(i32, lengthOfCurrentSequence + 1);
        for (currentSequence, 1..) |seq, index| {
            newSequence[index] = seq;
        }
        // If i defer the memory, I can't access the arrayList item.
        // defer allocator.free(newSequence);
        if (sequenceIndex == 0) {
            newSequence[0] = 0;
            continue;
        }

        var sequenceBelow = sequences.items[sequences.items.len - (sequenceIndex)];
        // we want to look BELOW to see what we should be adding...
        const diff = sequenceBelow[0];

        newSequence[0] = newSequence[1] - diff;

        sequences.items[sequenceLen - (1 + sequenceIndex)] = newSequence;
    }

    return sequences.items[0][0];
}

test "part one should solve" {
    try std.testing.expect(try solvePartOne(testData) == 114);
}

test "part two should solve" {
    try std.testing.expect(try solvePartTwo(testData) == 2);
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
