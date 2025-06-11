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

const ExitCode = enum(u8) {
    ok = 0,
    generic_error = 1,
    incorrect_usage = 2,

    pub fn to_u8(self: @This()) u8 {
        return @intFromEnum(self);
    }
};

const GnomeColorScheme = enum {
    default,
    @"prefer-dark",
    @"prefer-light",

    pub fn from_variant(variant: Variant) @This() {
        return switch (variant) {
            .system => .default,
            .dark => .@"prefer-dark",
            .light => .@"prefer-light",
        };
    }
};

const Variant = enum {
    system,
    dark,
    light,

    pub fn from_string(str: []const u8) ?@This() {
        inline for (@typeInfo(Variant).@"enum".fields) |field| {
            if (std.mem.eql(u8, field.name, str)) {
                return @enumFromInt(field.value);
            }
        }

        return null;
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

    const variant: Variant = Variant.from_string(initial_arg) orelse {
        std.log.err("Unknown variant \"{s}\".", .{initial_arg});
        return ExitCode.incorrect_usage.to_u8();
    };

    if (iter.next()) |_| {
        std.log.err("Too many arguments.", .{});
        return ExitCode.incorrect_usage.to_u8();
    }

    const gnome_color_scheme = GnomeColorScheme.from_variant(variant);

    {
        const result = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &.{
                "gsettings",
                "set",
                "org.gnome.desktop.interface",
                "color-scheme",
                @tagName(gnome_color_scheme),
            },
        });
        defer allocator.free(result.stdout);
        defer allocator.free(result.stderr);

        switch (result.term) {
            .Exited => |code| {
                if (code != 0) {
                    std.log.err("gsettings command exited with non-zero code: {d}", .{code});
                    return ExitCode.generic_error.to_u8();
                }
            },
            else => {
                std.log.err("gsettings command terminated unexpectedly.", .{});
                return ExitCode.generic_error.to_u8();
            },
        }

        std.log.info("Set GNOME color scheme to {s}", .{@tagName(gnome_color_scheme)});
    }

    return ExitCode.ok.to_u8();
}
