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

//! Over-powered theme switcher.

const std = @import("std");

const gnome = @import("./gnome.zig");
const Variant = @import("./variant.zig").Variant;

const ExitCode = enum(u8) {
    ok = 0,
    generic_error = 1,
    incorrect_usage = 2,

    pub fn to_u8(self: @This()) u8 {
        return @intFromEnum(self);
    }
};

const UnresolvedVariant = union(enum) {
    auto,
    manual: Variant,

    pub const FromStringError = error{
        UnknownType,
    };

    pub fn fromString(str: []const u8) FromStringError!@This() {
        if (std.mem.eql(u8, str, "auto")) {
            return .auto;
        }

        return .{
            .manual = Variant.fromString(str) catch return FromStringError.UnknownType,
        };
    }
};

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var iter = try std.process.ArgIterator.initWithAllocator(allocator);
    defer iter.deinit();

    // Skip program name.
    _ = iter.next();

    const initial_arg = iter.next() orelse {
        std.log.err("Argument is required.", .{});
        return ExitCode.incorrect_usage.to_u8();
    };

    const variant_unresolved = UnresolvedVariant.fromString(initial_arg) catch {
        std.log.err("Unknown variant \"{s}\".", .{initial_arg});
        return ExitCode.incorrect_usage.to_u8();
    };

    const variant: Variant = switch (variant_unresolved) {
        .auto => Variant.fromTime() catch |err| {
            std.log.err("Unable to resolve variant: {s}", .{@errorName(err)});
            return ExitCode.generic_error.to_u8();
        },
        .manual => |v| v,
    };

    if (iter.next()) |_| {
        std.log.err("Too many arguments.", .{});
        return ExitCode.incorrect_usage.to_u8();
    }

    gnome.apply(allocator, variant) catch {};

    return ExitCode.ok.to_u8();
}

test {
    _ = @import("./variant.zig");
}
