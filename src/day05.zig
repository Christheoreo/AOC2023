const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");
const testData = @embedFile("data/day05.test.txt");

const MapX = struct { destinationRangeStart: u64, sourceRangeStart: u64, rangeLength: u64 };

pub fn main() !void {
    var startTimePart = std.time.nanoTimestamp();
    var partOneAnswer = try solvePartOne(data);
    var elapsedTimePart: i128 = std.time.nanoTimestamp() - startTimePart;
    const oneMil: f128 = 1_000_000;
    var floatingPoint: f128 = @floatFromInt(elapsedTimePart);
    var mili: f128 = floatingPoint / oneMil;
    std.debug.print("Part 1 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    std.debug.print("Answer to part one is {}\n", .{partOneAnswer});

    // startTimePart = std.time.nanoTimestamp();
    // const partTwoAnswer = try solvePartTwo(data);
    // elapsedTimePart = std.time.nanoTimestamp() - startTimePart;

    // floatingPoint = @floatFromInt(elapsedTimePart);
    // mili = floatingPoint / oneMil;
    // std.debug.print("Part 2 took: {} nanoseconds and {} miliseconds\n", .{ elapsedTimePart, mili });
    // std.debug.print("Answer to part two is {}\n", .{partTwoAnswer});
}

fn solvePartOne(buffer: []const u8) !u32 {
    const allocator = std.heap.page_allocator;
    var lines = std.mem.splitAny(u8, buffer, "\n");
    var seedToSoilMaps = std.ArrayList(MapX).init(allocator);
    defer seedToSoilMaps.deinit();
    var lineIndex: usize = 0;
    var activeMapperIndex: u32 = 0;
    while (lines.next()) |line| {
        defer lineIndex += 1;
        if (line.len == 0) continue;
        const seedToSoil = "seed-to-soil map:";
        const soilToFert = "soil-to-fertilizer map:";
        const fertToWater = "fertilizer-to-water map:";
        const waterToLight = "water-to-light map:";
        const lightToTemp = "light-to-temperature map:";
        const tempToHumid = "temperature-to-humidity map:";
        const humidToLocation = "humidity-to-location map:";

        if (std.mem.eql(u8, line, seedToSoil)) {
            activeMapperIndex = 0;
            continue;
        }

        if (std.mem.eql(u8, line, soilToFert)) {
            activeMapperIndex = 1;
            continue;
        }

        if (std.mem.eql(u8, line, fertToWater)) {
            activeMapperIndex = 2;
            continue;
        }

        if (std.mem.eql(u8, line, waterToLight)) {
            activeMapperIndex = 3;
            continue;
        }

        if (std.mem.eql(u8, line, lightToTemp)) {
            activeMapperIndex = 4;
            continue;
        }

        if (std.mem.eql(u8, line, tempToHumid)) {
            activeMapperIndex = 5;
            continue;
        }

        if (std.mem.eql(u8, line, humidToLocation)) {
            activeMapperIndex = 6;
            continue;
        }

        // Should have a line with 3 numbers split by spaces

        var numbersAsBytesIterator = std.mem.splitAny(u8, lineIndex, " ");
        var m = MapX{ .destinationRangeStart = 0, .sourceRangeStart = 0, .rangeLength = 0 };
        var numbersAsBytesIteratorIndex: usize = 0;
        while (numbersAsBytesIterator) |xx| {
            defer numbersAsBytesIteratorIndex += 1;
            var number = try parseInt(u8, xx, 10);
            switch (numbersAsBytesIteratorIndex) {
                0 => {
                    m.destinationRangeStart = number;
                },
                1 => {
                    m.sourceRangeStart = number;
                },
                else => {
                    m.rangeLength = number;
                },
            }
        }

        switch (activeMapperIndex) {
            0 => {
                try seedToSoilMaps.append(m);
            },
            else => {
                //
            },
        }
        // std.debug.print("Line = {s} ({})\n", .{ line, line.len });
    }

    for (seedToSoilMaps) |s| {
        _ = s;
        // std.debug.print("", args: anytype);
    }

    // const seedToSoilMaps = allocator.alloc(comptime T: type, n: usize)
    return 0;
}

fn solvePartTwo(buffer: []const u8) !u32 {
    _ = buffer;
    return 0;
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
