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
    // var partOneAnswer = try solvePartOne(testData);
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

fn solvePartOne(buffer: []const u8) !u64 {
    const allocator = std.heap.page_allocator;
    var lines = std.mem.splitAny(u8, buffer, "\n");
    var seedToSoilMaps = std.ArrayList(MapX).init(allocator);
    var soilToFertMaps = std.ArrayList(MapX).init(allocator);
    var fertToWaterMaps = std.ArrayList(MapX).init(allocator);
    var waterToLightMaps = std.ArrayList(MapX).init(allocator);
    var lightToTempMaps = std.ArrayList(MapX).init(allocator);
    var tempToHumidMaps = std.ArrayList(MapX).init(allocator);
    var humidToLocationMaps = std.ArrayList(MapX).init(allocator);
    defer seedToSoilMaps.deinit();
    // TODO defer the rest
    var lineIndex: usize = 0;
    var activeMapperIndex: u32 = 0;
    var seeds = std.ArrayList(u64).init(allocator);
    var answer: u64 = 0;
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

        if (lineIndex == 0) {
            // the seeds
            var y = line[7..];
            var yIterator = std.mem.splitAny(u8, y, " ");
            while (yIterator.next()) |yy| {
                try seeds.append(try parseInt(u64, yy, 10));
            }
            continue;
        }

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

        var numbersAsBytesIterator = std.mem.splitAny(u8, line, " ");
        var m = MapX{ .destinationRangeStart = 0, .sourceRangeStart = 0, .rangeLength = 0 };
        var numbersAsBytesIteratorIndex: usize = 0;
        while (numbersAsBytesIterator.next()) |xx| {
            defer numbersAsBytesIteratorIndex += 1;
            var number = try parseInt(u64, xx, 10);
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
            1 => {
                try soilToFertMaps.append(m);
            },
            2 => {
                try fertToWaterMaps.append(m);
            },
            3 => {
                try waterToLightMaps.append(m);
            },
            4 => {
                try lightToTempMaps.append(m);
            },
            5 => {
                try tempToHumidMaps.append(m);
            },
            6 => {
                try humidToLocationMaps.append(m);
            },
            else => {
                //
            },
        }
        // std.debug.print("Line = {s} ({})\n", .{ line, line.len });
    }

    for (seeds.items) |seed| {
        // Start with seed to soil
        // is it withiin source range and destination range? if so, add the range.
        // conitnue here.
        var destValue: u64 = seed;
        for (seedToSoilMaps.items) |seedToSoilMap| {
            const mn: u64 = seedToSoilMap.sourceRangeStart;
            const mx: u64 = mn + seedToSoilMap.rangeLength;
            if (destValue >= mn and destValue <= mx) {
                destValue = (destValue - mn) + seedToSoilMap.destinationRangeStart;
                break;
            }
        }

        std.debug.print("After seed-to-soil value is {}\n", .{destValue});

        for (soilToFertMaps.items) |soilToFertMap| {
            const mn: u64 = soilToFertMap.sourceRangeStart;
            const mx: u64 = mn + soilToFertMap.rangeLength;
            if (destValue >= mn and destValue <= mx) {
                destValue = (destValue - mn) + soilToFertMap.destinationRangeStart;
                break;
            }
        }
        std.debug.print("After soil-to-fert value is {}\n", .{destValue});

        for (fertToWaterMaps.items) |fertoWaterMap| {
            const mn: u64 = fertoWaterMap.sourceRangeStart;
            const mx: u64 = mn + fertoWaterMap.rangeLength;
            if (destValue >= mn and destValue <= mx) {
                destValue = (destValue - mn) + fertoWaterMap.destinationRangeStart;
                break;
            }
        }

        std.debug.print("After fert-to-water value is {}\n", .{destValue});

        for (waterToLightMaps.items) |waterToLightMap| {
            const mn: u64 = waterToLightMap.sourceRangeStart;
            const mx: u64 = mn + waterToLightMap.rangeLength;
            if (destValue >= mn and destValue <= mx) {
                destValue = (destValue - mn) + waterToLightMap.destinationRangeStart;
                break;
            }
        }
        std.debug.print("After water-to-light value is {}\n", .{destValue});

        for (lightToTempMaps.items) |genericMap| {
            const mn: u64 = genericMap.sourceRangeStart;
            const mx: u64 = mn + genericMap.rangeLength;
            if (destValue >= mn and destValue <= mx) {
                destValue = (destValue - mn) + genericMap.destinationRangeStart;
                break;
            }
        }

        std.debug.print("After light-to-temp value is {}\n", .{destValue});

        for (tempToHumidMaps.items) |genericMap| {
            const mn: u64 = genericMap.sourceRangeStart;
            const mx: u64 = mn + genericMap.rangeLength;
            if (destValue >= mn and destValue <= mx) {
                destValue = (destValue - mn) + genericMap.destinationRangeStart;
                break;
            }
        }

        std.debug.print("After temp-to-humid value is {}\n", .{destValue});

        for (humidToLocationMaps.items) |genericMap| {
            const mn: u64 = genericMap.sourceRangeStart;
            const mx: u64 = mn + genericMap.rangeLength;
            if (destValue >= mn and destValue <= mx) {
                destValue = (destValue - mn) + genericMap.destinationRangeStart;
                break;
            }
        }

        std.debug.print("After humid-to-location value is {}\n\n\n\n", .{destValue});

        switch (answer) {
            0 => {
                answer = destValue;
            },
            else => {
                if (answer > destValue) {
                    answer = destValue;
                }
            },
        }
    }

    // const seedToSoilMaps = allocator.alloc(comptime T: type, n: usize)
    return answer;
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
