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

const std = @import("std");

const Variant = @import("./variant.zig").Variant;

const GnomeColorScheme = enum(c_int) {
    default = 0,
    @"prefer-dark" = 1,
    @"prefer-light" = 2,

    pub fn from_variant(variant: Variant) @This() {
        return switch (variant) {
            .system => .default,
            .dark => .@"prefer-dark",
            .light => .@"prefer-light",
        };
    }
};

pub const ApplyError = error{
    FailedToSpawnProcess,
    GsettingsCommandUnexpectedlyTerminated,
};

pub fn apply(allocator: std.mem.Allocator, variant: Variant) ApplyError!void {
    const gnome_color_scheme = GnomeColorScheme.from_variant(variant);

    const run_result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &.{
            "gsettings",
            "set",
            "org.gnome.desktop.interface",
            "color-scheme",
            @tagName(gnome_color_scheme),
        },
    }) catch |err| {
        std.log.err("Failed to run gsettings command: {s}", .{@errorName(err)});
        return ApplyError.FailedToSpawnProcess;
    };
    defer allocator.free(run_result.stdout);
    defer allocator.free(run_result.stderr);

    if (run_result.stderr.len > 0) {
        var stdout_writer = std.fs.File.stderr().writer(&.{});
        const stdout = &stdout_writer.interface;

        stdout.writeAll(run_result.stderr) catch |err| {
            std.log.err("Failed to write to stderr: {t}", .{err});
        };
    }

    switch (run_result.term) {
        .Exited => |code| {
            if (code != 0) {
                std.log.err("Non zero exit: {d}", .{code});
                return ApplyError.GsettingsCommandUnexpectedlyTerminated;
            }
        },
        .Signal => |sig| {
            std.log.err("Signal ({d})", .{sig});
            return ApplyError.GsettingsCommandUnexpectedlyTerminated;
        },
        else => {
            std.log.err("Process terminated abnormally", .{});
            return ApplyError.GsettingsCommandUnexpectedlyTerminated;
        },
    }

    std.log.info("Set GNOME color scheme to {s}", .{@tagName(gnome_color_scheme)});
}
