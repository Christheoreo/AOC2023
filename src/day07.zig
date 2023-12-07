const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");
const testData = @embedFile("data/day07.test.txt");
const HandType = enum(u32) { FiveOfAKind = 7, FourOfAKind = 6, FullHouse = 5, ThreeOfAKind = 4, TwoPair = 3, OnePair = 2, HighCard = 1 };
const Hand = struct { cards: [5]u8, bid: u32, handType: HandType };
const cardOrder = [_]u8{ 'A', 'K', 'Q', 'J', 10, 9, 8, 7, 6, 5, 4, 3, 2 };

pub fn main() !void {
    var startTimePart = std.time.nanoTimestamp();
    // var partOneAnswer = try solvePartOne(testData);
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
    var answer: u32 = 0;
    var lines = std.mem.splitAny(u8, buffer, "\n");
    var lineIndex: usize = 0;
    var allocator = std.heap.page_allocator;
    var hands = std.ArrayList(Hand).init(allocator);
    hands.deinit();

    var handsTypes = std.ArrayList(u32).init(allocator);
    handsTypes.deinit();

    while (lines.next()) |line| {
        defer lineIndex += 1;
        const bidBytes = line[6..];
        // const cards = line[0..5];
        const cards: [5]u8 = [5]u8{ line[0], line[1], line[2], line[3], line[4] };

        const hand = Hand{ .cards = cards, .handType = try findHandType(cards), .bid = try parseInt(u32, bidBytes, 10) };

        try hands.append(hand);
        var val: u32 = @intFromEnum(hand.handType);
        try handsTypes.append(val);

        std.debug.print("Bid Bytes .{s}.\n", .{bidBytes});
        std.debug.print("Cards .{s}.\n", .{cards});
        std.debug.print("Hand Type .{any}.\n\n\n", .{hand.handType});
    }

    // std.mem.sort(u32, handsTypes.items, {}, comptime std.sort.desc(u32));
    std.mem.sort(Hand, hands.items, {}, comptime compareHands);

    for (handsTypes.items) |xxx| {
        std.debug.print("value is {}\n", .{xxx});
    }
    var rank: u32 = 1;
    for (hands.items) |xxx| {
        defer rank += 1;
        answer += rank * xxx.bid;
        std.debug.print("value is {s}\n", .{xxx.cards});
    }
    // std.mem.sort(Hand, hands.items, {}, ());

    // Now we need to sort the hands
    return answer;
}

// Define a comparison function for sorting persons by age
fn compareHands(_: void, a: Hand, b: Hand) bool {
    if (a.handType == b.handType) {
        // now check the cards line by line
        var index: usize = 0;
        while (index < a.cards.len) : (index += 1) {
            var byteA = a.cards[index];
            var byteB = b.cards[index];
            if (byteA == byteB) continue;
            return byteA > byteB;
        }
    }

    return @intFromEnum(a.handType) < @intFromEnum(b.handType);
}

pub fn solvePartTwo(buffer: []const u8) !u32 {
    _ = buffer;
    return 0;
}

fn findHandType(cards: [5]u8) !HandType {
    var allocator = std.heap.page_allocator;
    var map = std.AutoHashMap(u8, u32).init(
        allocator,
    );
    defer map.deinit();
    for (cards) |card| {
        if (map.get(card)) |val| {
            try map.put(card, val + 1);
            continue;
        }
        try map.put(card, 1);
    }

    if (map.count() == 1) return HandType.FiveOfAKind;

    if (map.count() == 2) {
        // it can either be 4 of a kind or a full house
        if (map.get(cards[0]).? == 4 or map.get(cards[0]).? == 1) return HandType.FourOfAKind;
        return HandType.FullHouse;
    }

    // if the count is 3, its eight a 2 pair or a three of a kind

    if (map.count() == 3) {
        if (map.get(cards[0]).? == 3 or map.get(cards[1]).? == 3 or map.get(cards[2]).? == 3) return HandType.ThreeOfAKind;
        return HandType.TwoPair;
    }

    if (map.count() == 4) {
        return HandType.OnePair;
    }
    // Check for one pair and High card

    return HandType.HighCard;
}

test "part one should solve" {
    try std.testing.expect(try solvePartOne(testData) == 6440);
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
