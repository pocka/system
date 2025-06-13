// Copyright 2025 Shota FUJI <pockawoooh@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

const config = @import("config");
const std = @import("std");

const time = @cImport({
    @cInclude("time.h");
});

const stdlib = @cImport({
    @cInclude("stdlib.h");
});

pub const Variant = enum {
    system,
    dark,
    light,

    pub const FromStringError = error{
        UnknownVariant,
    };

    pub fn fromString(str: []const u8) FromStringError!@This() {
        inline for (@typeInfo(Variant).@"enum".fields) |field| {
            if (std.mem.eql(u8, field.name, str)) {
                return @enumFromInt(field.value);
            }
        }

        return FromStringError.UnknownVariant;
    }

    fn ensureZoneinfoDir() void {
        const existing = stdlib.getenv("TZDIR");
        if (existing) |tzdir| {
            if (std.mem.span(tzdir).len > 0) {
                return;
            }
        }

        const fallback = config.tzdir orelse return;
        const set_result = stdlib.setenv("TZDIR", fallback, 1);
        if (set_result != 0) {
            std.log.warn("Failed to set $TZDIR to {s}: {d}", .{
                fallback,
                set_result,
            });
        }
    }

    pub fn fromTime() TimeRange.InitError!@This() {
        ensureZoneinfoDir();
        time.tzset();

        var now: time.time_t = undefined;
        _ = time.time(&now);

        var now_tm: time.tm = undefined;
        _ = time.localtime_r(&now, &now_tm);

        const dark_mode_range = try TimeRange.init(
            &now_tm,
            config.dark_mode_start,
            config.dark_mode_end,
        );

        return if (dark_mode_range.isIntersecting(now)) .dark else .light;
    }
};

const ParseTimeError = error{
    IncorrectFormat,
};

fn parseTime(now: *const time.tm, str: []const u8) ParseTimeError!time.time_t {
    if (str.len != 5) {
        return ParseTimeError.IncorrectFormat;
    }

    var iter = std.mem.splitScalar(u8, str, ':');

    const hour_str = iter.next() orelse return ParseTimeError.IncorrectFormat;
    const min_str = iter.next() orelse return ParseTimeError.IncorrectFormat;

    var t: time.tm = now.*;
    t.tm_hour = std.fmt.parseInt(u6, hour_str, 10) catch return ParseTimeError.IncorrectFormat;
    t.tm_min = std.fmt.parseInt(u6, min_str, 10) catch return ParseTimeError.IncorrectFormat;

    return time.mktime(&t);
}

test "parseTime should parse hh:mm string" {
    const Suite = struct {
        input: []const u8,
        expected_hour: u6,
        expected_min: u6,
    };

    const suites = [_]Suite{
        .{
            .input = "00:00",
            .expected_hour = 0,
            .expected_min = 0,
        },
        .{
            .input = "08:31",
            .expected_hour = 8,
            .expected_min = 31,
        },
        .{
            .input = "23:59",
            .expected_hour = 23,
            .expected_min = 59,
        },
        .{
            .input = "24:00",
            .expected_hour = 0,
            .expected_min = 0,
        },
    };

    for (suites) |suite| {
        const date = time.tm{
            .tm_isdst = -1,
            .tm_year = 2001,
            .tm_mon = 2,
            .tm_mday = 9,
        };

        const parsed = try parseTime(&date, suite.input);

        var parsed_tm: time.tm = undefined;
        _ = time.localtime_r(&parsed, &parsed_tm);

        try std.testing.expectEqual(suite.expected_hour, parsed_tm.tm_hour);
        try std.testing.expectEqual(suite.expected_min, parsed_tm.tm_min);
    }
}

test "parseTime should reject invalid formats" {
    const suites = [_][]const u8{
        "",
        "     ",
        " 0:11",
        "07:30PM",
        "aa:bb",
        "01-10",
        "0832",
        "23.56",
        "seven",
    };

    for (suites) |suite| {
        const date = time.tm{
            .tm_isdst = -1,
            .tm_year = 2001,
            .tm_mon = 2,
            .tm_mday = 9,
        };

        const result = parseTime(&date, suite);

        try std.testing.expectError(ParseTimeError.IncorrectFormat, result);
    }
}

pub const TimeRange = struct {
    start: time.time_t,
    end: time.time_t,

    pub const InitError = error{
        IncorrectStartTimeFormat,
        IncorrectEndTimeFormat,
        StartAndEndTimeEquals,
    };

    const whole_day: time.time_t = 24 * 60 * 60;

    pub fn init(now: *const time.tm, start_str: []const u8, end_str: []const u8) InitError!@This() {
        const start = parseTime(now, start_str) catch return InitError.IncorrectStartTimeFormat;
        var end = parseTime(now, end_str) catch return InitError.IncorrectEndTimeFormat;

        const diff = time.difftime(end, start);

        if (diff == 0) {
            return InitError.StartAndEndTimeEquals;
        } else if (diff < 0) {
            end += whole_day;
        }

        return .{
            .start = start,
            .end = end,
        };
    }

    pub fn isIntersecting(self: *const @This(), x: time.time_t) bool {
        if (self.start <= x and self.end >= x) {
            return true;
        }

        if ((self.start - whole_day) <= x and (self.end - whole_day) >= x) {
            return true;
        }

        return ((self.start + whole_day) <= x and (self.end + whole_day) >= x);
    }
};

test TimeRange {
    const date = time.tm{
        .tm_isdst = -1,
        .tm_year = 2001,
        .tm_mon = 2,
        .tm_mday = 9,
    };

    const Suite = struct {
        start: []const u8,
        end: []const u8,

        inside: []const time.time_t = &.{},
        outside: []const time.time_t = &.{},

        pub fn formatTime(allocator: std.mem.Allocator, t: time.time_t) ![]const u8 {
            var tm: time.tm = undefined;
            _ = time.localtime_r(&t, &tm);

            const year: u32 = @intCast(tm.tm_year);
            const month: u32 = @intCast(tm.tm_mon + 1);
            const day: u5 = @intCast(tm.tm_mday);
            const hour: u6 = @intCast(tm.tm_hour);
            const min: u6 = @intCast(tm.tm_min);

            return std.fmt.allocPrint(allocator, "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}", .{
                year,
                month,
                day,
                hour,
                min,
            });
        }
    };

    const suites = [_]Suite{
        .{
            .start = "08:30",
            .end = "17:30",
            .inside = &.{
                try parseTime(&date, "08:30"),
                try parseTime(&date, "08:31"),
                try parseTime(&date, "09:00"),
                try parseTime(&date, "17:29"),
                try parseTime(&date, "17:30"),
            },
            .outside = &.{
                try parseTime(&date, "00:00"),
                try parseTime(&date, "08:29"),
                try parseTime(&date, "17:31"),
            },
        },
        .{
            .start = "18:00",
            .end = "08:00",
            .inside = &.{
                try parseTime(&date, "00:00"),
                try parseTime(&date, "08:00"),
                try parseTime(&date, "07:59"),
                try parseTime(&date, "18:00"),
                try parseTime(&date, "22:59"),
            },
            .outside = &.{
                try parseTime(&date, "08:30"),
                try parseTime(&date, "12:00"),
                try parseTime(&date, "17:59"),
            },
        },
    };

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    for (suites) |suite| {
        const range = try TimeRange.init(&date, suite.start, suite.end);

        try std.testing.expect(range.end > range.start);

        for (suite.inside) |t| {
            std.testing.expect(range.isIntersecting(t)) catch |err| {
                std.log.err("{s} is not inside {s}~{s}", .{
                    try Suite.formatTime(allocator, t),
                    try Suite.formatTime(allocator, range.start),
                    try Suite.formatTime(allocator, range.end),
                });
                return err;
            };
        }

        for (suite.outside) |t| {
            std.testing.expect(!range.isIntersecting(t)) catch |err| {
                std.log.err("{s} is not outside {s}~{s}", .{
                    try Suite.formatTime(allocator, t),
                    try Suite.formatTime(allocator, range.start),
                    try Suite.formatTime(allocator, range.end),
                });
                return err;
            };
        }
    }
}
