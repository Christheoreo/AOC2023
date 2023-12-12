const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");
const testData = @embedFile("data/day11.test.txt");

const Node = struct { isGalaxy: bool, up: ?*Node, right: ?*Node, left: ?*Node, down: ?*Node };

pub fn main() !void {
    var startTimePart = std.time.nanoTimestamp();
    var partOneAnswer = try solvePartOne(testData);
    var elapsedTimePart: i128 = std.time.nanoTimestamp() - startTimePart;
    const oneMil: f128 = 1_000_000;
    var floatingPoint: f128 = @floatFromInt(elapsedTimePart);
    var mili: f128 = floatingPoint / oneMil;
    std.debug.print("Part 1 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    std.debug.print("Answer to part one is {}\n", .{partOneAnswer});

    startTimePart = std.time.nanoTimestamp();
    const partTwoAnswer = try solvePartTwo(testData);
    elapsedTimePart = std.time.nanoTimestamp() - startTimePart;

    floatingPoint = @floatFromInt(elapsedTimePart);
    mili = floatingPoint / oneMil;
    std.debug.print("Part 2 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    std.debug.print("Answer to part two is {}\n", .{partTwoAnswer});
}

pub fn solvePartOne(buffer: []const u8) !u32 {
    var lines = std.mem.splitAny(u8, buffer, "\n");
    var lineIndex: usize = 0;
    var allocator = std.heap.page_allocator;
    var grid = std.ArrayList([]u8).init(allocator);
    defer grid.deinit();
    var answer: u32 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;
        var l = std.ArrayList(u8).init(allocator);

        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            try l.append(line[i]);
        }
        try grid.append(l.items);

        if (!std.mem.containsAtLeast(u8, line, 1, "#")) {
            try grid.append(l.items);
        }
    }

    var colIndex: u32 = 0;
    var columnsToAdd = std.ArrayList(u32).init(allocator);
    while (colIndex < grid.items[0].len) : (colIndex += 1) {
        var rowIndex: usize = 0;
        var containsGalaxy: bool = false;
        while (rowIndex < grid.items.len) : (rowIndex += 1) {
            var row = grid.items[rowIndex];
            if (row[colIndex] == '#') {
                containsGalaxy = true;
                break;
            }
        }
        if (containsGalaxy) continue;
        try columnsToAdd.append(colIndex);
    }

    std.debug.print("items in cols to add = {}\n", .{columnsToAdd.items.len});
    for (columnsToAdd.items, 1..) |colItem, ii| {
        // we have marked the column indexs - but we add new ones - so we need to get past that
        std.debug.print("Col = {}\n", .{colItem});
        // Add a column after this one!
        var currentRow: usize = 0;
        while (currentRow < grid.items.len) : (currentRow += 1) {
            // Add an item at col + 1!
            var newRow = try allocator.alloc(u8, grid.items[currentRow].len + 1);
            var r = grid.items[currentRow];

            var k: usize = 0;
            newRow[colItem + ii] = '.';
            while (k < r.len) : (k += 1) {
                if (k <= colItem + ii) {
                    newRow[k] = r[k];
                } else {
                    newRow[k + ii] = r[k];
                }
            }

            grid.items[currentRow] = newRow;
        }
        // colIndex += 1;
        // if (colIndex >= grid.items[0].len - 1) {
        //     break;
        // }
    }

    for (grid.items) |line| {
        std.debug.print("{s}\n", .{line});
    }
    return answer;
}

// fn insertLineAfterPos(pos: u32, grid)

pub fn solvePartTwo(buffer: []const u8) !u32 {
    _ = buffer;
    return 0;
}

test "part one should solve" {
    try std.testing.expect(try solvePartOne(testData) == 0);
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
