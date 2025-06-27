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

allocator: std.mem.Allocator,
file_path: []const u8,
class: ?[]const u8 = null,
trim_markdown_list_prefix: bool = false,

pub const InitError = error{
    IncorrectUsage,
    ShowHelp,
} || std.mem.Allocator.Error || std.fs.Dir.RealPathAllocError;

const class_arg_prefix = "--class=";

pub const helpText =
    \\,waybar-text - Watches text file and print its first line
    \\
    \\[USAGE]
    \\,waybar-text [--class=string] <FILE>
    \\
    \\[OPTIONS]
    \\--help         Print this message to stdout and exits.
    \\--class=string Set CSS class for the output text.
    \\--trim-md-list Trim markdown list prefixes from displaying text.
    \\
;

pub fn init(allocator: std.mem.Allocator) InitError!@This() {
    var iter = try std.process.ArgIterator.initWithAllocator(allocator);
    defer iter.deinit();

    // Skip program name.
    _ = iter.next();

    var first_positional_arg: ?[]const u8 = null;

    var class: ?[]const u8 = null;
    errdefer if (class) |slice| allocator.free(slice);

    var trim_markdown_list_prefix: bool = false;

    while (iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "--help")) {
            return InitError.ShowHelp;
        }

        if (std.mem.startsWith(u8, arg, class_arg_prefix)) {
            if (class) |_| {
                std.log.err("--class can't be used more than once", .{});
                return InitError.IncorrectUsage;
            }

            class = try allocator.dupe(u8, arg[class_arg_prefix.len..]);
            if (class) |c| if (c.len == 0) {
                std.log.err("--class requires a value", .{});
                return InitError.IncorrectUsage;
            };

            continue;
        }

        if (std.mem.eql(u8, arg, "--trim-md-list")) {
            trim_markdown_list_prefix = true;
            continue;
        }

        if (std.mem.startsWith(u8, arg, "-")) {
            std.log.err("Unknown option: {s}", .{arg});
            return InitError.IncorrectUsage;
        }

        if (first_positional_arg) |_| {
            std.log.err("FILE can't be used more than once", .{});
            return InitError.IncorrectUsage;
        }

        first_positional_arg = arg;
    }

    const cwd = std.fs.cwd();

    const file = try cwd.realpathAlloc(allocator, first_positional_arg orelse {
        std.log.err("FILE is required", .{});
        return InitError.IncorrectUsage;
    });

    return .{
        .allocator = allocator,
        .file_path = file,
        .class = class,
        .trim_markdown_list_prefix = trim_markdown_list_prefix,
    };
}

pub fn deinit(self: *const @This()) void {
    self.allocator.free(self.file_path);
    if (self.class) |class| self.allocator.free(class);
}
