const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");
const testData = @embedFile("data/day04.test.txt");
const splitter = [1]u8{'|'};
const space = [1]u8{' '};
const colon = [1]u8{':'};
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
    var lines = std.mem.split(u8, buffer, "\n");
    var lineIndex: u16 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;

        const indexOfColon = std.mem.indexOfAny(u8, line, &colon).?;
        var content = line[indexOfColon..];
        const indexOfSplitter = std.mem.indexOfAny(u8, content, &splitter).?;

        var winningNumbers = content[2 .. indexOfSplitter - 1];
        winningNumbers = std.mem.trim(u8, winningNumbers, &space);
        var yourNumbers = content[indexOfSplitter + 2 ..];
        var winningCharsIterator = split(u8, winningNumbers, &space);
        var yourCharsIterator = split(u8, yourNumbers, &space);

        var sum: u32 = 0;
        while (winningCharsIterator.next()) |digitsAsBytes| {
            if (std.mem.eql(u8, digitsAsBytes, &space) or digitsAsBytes.len == 0) continue;
            yourCharsIterator = split(u8, yourNumbers, &space);
            while (yourCharsIterator.next()) |yourDigitsAsBytes| {
                if (std.mem.eql(u8, yourDigitsAsBytes, &space) or yourDigitsAsBytes.len == 0) continue;
                if (std.mem.eql(u8, digitsAsBytes, yourDigitsAsBytes)) {
                    // std.debug.print("Found '{s}' in {s}\n", .{ digitsAsBytes, yourDigitsAsBytes });
                    switch (sum) {
                        0 => {
                            sum = 1;
                        },
                        else => {
                            sum *= 2;
                        },
                    }
                    break;
                }
            }
        }

        answer += sum;
    }
    //
    return answer;
}

pub fn solvePartTwo(buffer: []const u8) !u32 {
    var lines = std.mem.split(u8, buffer, "\n");
    var answer: u32 = 0;
    var allocator = std.heap.page_allocator;
    var rowCount: u32 = 0;
    while (lines.next()) |_| {
        rowCount += 1;
    }
    lines = std.mem.split(u8, buffer, "\n");
    const rowBuffer = try allocator.alloc(u32, rowCount);
    defer allocator.free(rowBuffer);

    var rowIndex: u32 = 0;

    while (rowIndex < rowCount) : (rowIndex += 1) {
        rowBuffer[rowIndex] = 1;
    }

    var lineIndex: u16 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;

        var amountOfThisScratchCard: u32 = rowBuffer[lineIndex];

        const indexOfColon = std.mem.indexOfAny(u8, line, &colon).?;
        var content = line[indexOfColon..];

        const indexOfSplitter = std.mem.indexOfAny(u8, content, &splitter).?;

        var winningNumbers = content[2 .. indexOfSplitter - 1];
        winningNumbers = std.mem.trim(u8, winningNumbers, &space);
        var yourNumbers = content[indexOfSplitter + 2 ..];
        var winningCharsIterator = split(u8, winningNumbers, &space);
        var yourCharsIterator = split(u8, yourNumbers, &space);

        var scratchCardsWon: u32 = 0;
        while (winningCharsIterator.next()) |digitsAsBytes| {
            if (std.mem.eql(u8, digitsAsBytes, &space) or digitsAsBytes.len == 0) continue;
            yourCharsIterator = split(u8, yourNumbers, &space);
            while (yourCharsIterator.next()) |yourDigitsAsBytes| {
                if (std.mem.eql(u8, yourDigitsAsBytes, &space) or yourDigitsAsBytes.len == 0) continue;
                if (std.mem.eql(u8, digitsAsBytes, yourDigitsAsBytes)) {
                    scratchCardsWon += 1;
                }
            }
        }

        var i: u32 = 1;
        while (i <= scratchCardsWon and lineIndex + i < rowBuffer.len) : (i += 1) {
            rowBuffer[lineIndex + i] += amountOfThisScratchCard;
        }
    }
    for (rowBuffer) |row| {
        answer += row;
    }
    return answer;
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
