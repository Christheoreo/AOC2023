const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");
const testData = @embedFile("data/day10.test.txt");

const EPipeType = enum(u8) { Vertical = '|', Horizontal = '-', QuaterBendNorthToEast = 'L', QuaterBendNorthToWest = 'J', QuaterBendSouthToWest = '7', QuaterBendSouthToEast = 'F', Ground = '.', Animal = 'S' };
const PipeJourney = struct { pos: @Vector(2, u32), direction: u8 };
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
    const partTwoAnswer = try solvePartTwo(testData);
    elapsedTimePart = std.time.nanoTimestamp() - startTimePart;

    floatingPoint = @floatFromInt(elapsedTimePart);
    mili = floatingPoint / oneMil;
    std.debug.print("Part 2 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    std.debug.print("Answer to part two is {}\n", .{partTwoAnswer});
}

pub fn solvePartOne(buffer: []const u8) !u32 {
    var lines = std.mem.splitAny(u8, buffer, "\n");
    var lineCount: u32 = @intCast(std.mem.count(u8, buffer, "\n"));
    lineCount += 1;
    var allocator = std.heap.page_allocator;
    var grid = try allocator.alloc([]u8, lineCount);
    defer allocator.free(grid);
    var lineIndex: u32 = 0;
    var x: u32 = 0;
    var y: u32 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;
        var gridLine = try allocator.alloc(u8, line.len);
        // defer allocator.free(gridLine);
        var i: u32 = 0;
        // std.debug.print("grid line length = {}\n", .{gridLine.len});
        while (i < line.len) : (i += 1) {
            gridLine[i] = line[i];
            if (gridLine[i] == 'S') {
                x = i;
                y = lineIndex;
            }
        }
        grid[lineIndex] = gridLine;
    }

    // Check up down left and right to see where our 2 connecting points are

    var connectionA: @Vector(2, u32) = .{ x, y };
    var connectionB: @Vector(2, u32) = .{ x, y };

    connectionA = findNextConnection(grid, connectionA, connectionA);
    connectionB = findNextConnection(grid, connectionB, connectionA);
    var journeyA = PipeJourney{ .pos = connectionA, .direction = 'W' };
    var journeyB = PipeJourney{ .pos = connectionB, .direction = 'W' };

    if (connectionA[0] > x) {
        journeyA.direction = 'E';
    } else if (connectionA[1] > y) {
        journeyA.direction = 'S';
    } else if (connectionA[1] < y) {
        journeyA.direction = 'N';
    }

    if (connectionB[0] > x) {
        journeyB.direction = 'E';
    } else if (connectionB[1] > y) {
        journeyB.direction = 'S';
    } else if (connectionB[1] < y) {
        journeyB.direction = 'N';
    }

    var steps: u32 = 1;
    while (!std.meta.eql(journeyA.pos, journeyB.pos)) {
        defer steps += 1;
        journeyA = findNextMove(grid, journeyA);
        journeyB = findNextMove(grid, journeyB);
    }

    // std.debug.print("Length of grid = {}\n", .{grid.len});
    // std.debug.print("Connection A = {}\n", .{connectionA});
    // std.debug.print("Connection B = {}\n", .{connectionB});
    // for (grid) |gg| {
    //     std.debug.print("Gridline = {s}\n", .{gg});
    // }
    // Assuming the S only has 2 connections. Then will work around.
    return steps;
}

fn findNextConnection(grid: [][]u8, animal: @Vector(2, u32), firstConnection: @Vector(2, u32)) @Vector(2, u32) {
    // Check left
    if (animal[0] > 0) {
        const left: @Vector(2, u32) = .{ animal[0] - 1, animal[1] };
        if (!std.meta.eql(left, firstConnection)) {
            const val: EPipeType = @enumFromInt(grid[animal[1]][animal[0] - 1]);
            if (val == EPipeType.Horizontal or val == EPipeType.QuaterBendNorthToEast or val == EPipeType.QuaterBendSouthToEast) {
                // found connectuionA
                return .{ animal[0] - 1, animal[1] };
            }
        }
    }
    // Check up
    if (animal[1] > 0) {
        const up: @Vector(2, u32) = .{ animal[0], animal[1] - 1 };
        if (!std.meta.eql(up, firstConnection)) {
            const val: EPipeType = @enumFromInt(grid[animal[1] - 1][animal[0]]);
            if (val == EPipeType.Vertical or val == EPipeType.QuaterBendSouthToEast or val == EPipeType.QuaterBendSouthToWest) {
                // found connectuionA
                return .{ animal[0], animal[1] - 1 };
            }
        }
    }
    // check right
    if (animal[0] + 1 < grid[0].len) {
        const right: @Vector(2, u32) = .{ animal[0] + 1, animal[1] };
        if (!std.meta.eql(right, firstConnection)) {
            const val: EPipeType = @enumFromInt(grid[animal[1]][animal[0] + 1]);
            if (val == EPipeType.Horizontal or val == EPipeType.QuaterBendNorthToWest or val == EPipeType.QuaterBendSouthToWest) {
                // found connectuionA
                return .{ animal[0] + 1, animal[1] };
            }
        }
    }

    // Check down
    if (animal[1] + 1 < grid.len) {
        const down: @Vector(2, u32) = .{ animal[0], animal[1] + 1 };
        if (!std.meta.eql(down, firstConnection)) {
            const val: EPipeType = @enumFromInt(grid[animal[1] + 1][animal[0]]);
            if (val == EPipeType.Vertical or val == EPipeType.QuaterBendNorthToEast or val == EPipeType.QuaterBendNorthToWest) {
                // found connectuionA
                return .{ animal[0], animal[1] + 1 };
            }
        }
    }
    return .{ 0, 0 };
}

fn findNextMove(grid: [][]u8, pos: PipeJourney) PipeJourney {
    var pipe: EPipeType = @enumFromInt(grid[pos.pos[1]][pos.pos[0]]);
    // var nextPos: @Vector(2, u32) = .{ pos.pos[0], pos.pos[1] };
    var nextJourney = PipeJourney{ .pos = .{ pos.pos[0], pos.pos[1] }, .direction = pos.direction };
    switch (pos.direction) {
        'E' => {
            switch (pipe) {
                EPipeType.Horizontal => {
                    nextJourney.pos[0] += 1;
                    // Direction is the same
                },
                EPipeType.QuaterBendNorthToWest => {
                    nextJourney.pos[1] -= 1;
                    nextJourney.direction = 'N';
                },
                EPipeType.QuaterBendSouthToWest => {
                    nextJourney.pos[1] += 1;
                    nextJourney.direction = 'S';
                },
                else => {
                    //
                },
            }
        },
        'W' => {
            switch (pipe) {
                EPipeType.Horizontal => {
                    nextJourney.pos[0] -= 1;
                    // Direction is the same
                },
                EPipeType.QuaterBendNorthToEast => {
                    nextJourney.pos[1] -= 1;
                    nextJourney.direction = 'N';
                },
                EPipeType.QuaterBendSouthToEast => {
                    nextJourney.pos[1] += 1;
                    nextJourney.direction = 'S';
                },
                else => {
                    //
                },
            }
        },
        'N' => {
            switch (pipe) {
                EPipeType.Vertical => {
                    nextJourney.pos[1] -= 1;
                    // Direction is the same
                },
                EPipeType.QuaterBendSouthToEast => {
                    nextJourney.pos[0] += 1;
                    nextJourney.direction = 'E';
                },
                EPipeType.QuaterBendSouthToWest => {
                    nextJourney.pos[0] -= 1;
                    nextJourney.direction = 'W';
                },
                else => {
                    //
                },
            }
        },
        else => {
            switch (pipe) {
                EPipeType.Vertical => {
                    nextJourney.pos[1] += 1;
                    // Direction is the same
                },
                EPipeType.QuaterBendNorthToEast => {
                    nextJourney.pos[0] += 1;
                    nextJourney.direction = 'E';
                },
                EPipeType.QuaterBendNorthToWest => {
                    nextJourney.pos[0] -= 1;
                    nextJourney.direction = 'W';
                },
                else => {
                    //
                },
            }
        },
    }

    return nextJourney;
}

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
