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

//! Watches specified file and print its first line in waybar output JSON.

const std = @import("std");

const Options = @import("./Options.zig");
const waybar = @import("./waybar.zig");

const ExitCode = enum(u8) {
    ok = 0,
    unknown_error = 1,
    incorrect_usage = 2,
    read_permission_error = 3,
    file_watch_error = 4,
    out_of_memory = 5,
    file_not_found = 6,

    pub fn to_u8(self: @This()) u8 {
        return @intFromEnum(self);
    }
};

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const options = Options.init(allocator) catch |err| switch (err) {
        error.IncorrectUsage => {
            var stderr = std.fs.File.stderr().writer(&.{});
            const writer = &stderr.interface;

            try writer.writeAll(Options.helpText);
            return ExitCode.incorrect_usage.to_u8();
        },
        error.ShowHelp => {
            var stdout = std.fs.File.stdout().writer(&.{});
            const writer = &stdout.interface;

            try writer.writeAll(Options.helpText);
            return ExitCode.ok.to_u8();
        },
        error.OutOfMemory => {
            std.log.err("Out of memory", .{});
            return ExitCode.out_of_memory.to_u8();
        },
        error.FileNotFound => {
            std.log.err("File not found", .{});
            return ExitCode.file_not_found.to_u8();
        },
        else => {
            std.log.err("Unexpected error: {s}", .{@errorName(err)});
            return ExitCode.unknown_error.to_u8();
        },
    };
    defer options.deinit();

    print(allocator, &options) catch |err| switch (err) {
        error.OutOfMemory => {
            std.log.err("Out of memory", .{});
            return ExitCode.out_of_memory.to_u8();
        },
        else => {
            std.log.err("Unexpected error: {s}", .{@errorName(err)});
            return ExitCode.unknown_error.to_u8();
        },
    };

    watch(allocator, &options) catch |err| switch (err) {
        error.FileNotFound => {
            std.log.err("File not found", .{});
            return ExitCode.file_not_found.to_u8();
        },
        else => {
            std.log.err("Unexpected error: {s}", .{@errorName(err)});
            return ExitCode.unknown_error.to_u8();
        },
    };

    return ExitCode.ok.to_u8();
}

fn print(allocator: std.mem.Allocator, opts: *const Options) !void {
    const file = try std.fs.openFileAbsolute(opts.file_path, .{});
    defer file.close();

    // Most of my lines falls under 100 characters and do not contain
    // non-ASCII range.
    var file_buffer: [128]u8 = undefined;
    var file_reader = file.reader(&file_buffer);
    const reader = &file_reader.interface;

    var line_writer = std.Io.Writer.Allocating.init(allocator);
    defer line_writer.deinit();

    _ = reader.streamDelimiter(&line_writer.writer, '\n') catch |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    };

    const line = try line_writer.toOwnedSlice();
    defer allocator.free(line);

    const line_trimmed: []const u8 = if (opts.trim_markdown_list_prefix) line_start: {
        if (line.len < 2) {
            break :line_start line;
        }

        break :line_start switch (line[0]) {
            '*', '-', '+' => line[(std.mem.indexOfNonePos(u8, line, 1, " \t") orelse 0)..],
            else => line,
        };
    } else line;

    const output = waybar.ModuleOutput{
        .text = line_trimmed,
        .tooltip = line_trimmed,
        .class = opts.class,
    };

    var output_buffer: [1024]u8 = undefined;
    var output_writer = std.fs.File.stdout().writer(&output_buffer);
    const writer = &output_writer.interface;

    try output.encode(writer);
    try writer.writeByte('\n');
    try writer.flush();
}

const watch_flags = std.os.linux.IN.MODIFY | std.os.linux.IN.DELETE_SELF;

fn watch(allocator: std.mem.Allocator, opts: *const Options) !void {
    const fd = try std.posix.inotify_init1(0);
    defer std.posix.close(fd);

    var wd = try std.posix.inotify_add_watch(fd, opts.file_path, watch_flags);
    defer std.posix.inotify_rm_watch(fd, wd);

    var buffer: [64]std.os.linux.inotify_event = undefined;
    while (true) {
        const read_bytes = try std.posix.read(fd, std.mem.sliceAsBytes(&buffer));

        var i: usize = 0;
        while (i < read_bytes) : (i += buffer[i].len + @sizeOf(std.os.linux.inotify_event)) {
            const event = buffer[i];

            // Certain text editors (I mean, vim/neovim) creates a new file and remove the old one
            // instead of writing to the file. We have to watch the new file otherwise no events
            // will be fired for the path anymore.
            if (event.mask & std.os.linux.IN.DELETE_SELF != 0) {
                wd = try std.posix.inotify_add_watch(fd, opts.file_path, watch_flags);
                continue;
            }

            if (event.mask & std.os.linux.IN.MODIFY != 0) {
                print(allocator, opts) catch |err| {
                    std.log.warn("Unable to print: {s}", .{@errorName(err)});
                };
            }
        }
    }
}
