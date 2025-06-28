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

const Config = @import("./Config.zig");
const gnome = @import("./gnome.zig");
const sunwait = @import("./sunwait.zig");
const Variant = @import("./variant.zig").Variant;

pub const std_options = std.Options{
    .log_level = .debug,
    .logFn = log,
};

var log_level: std.log.Level = .info;

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    if (@intFromEnum(level) <= @intFromEnum(log_level)) {
        std.log.defaultLog(level, scope, format, args);
    }
}

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

fn apply(allocator: std.mem.Allocator, variant: Variant) ExitCode {
    gnome.apply(allocator, variant) catch {};
    return ExitCode.ok;
}

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var iter = try std.process.ArgIterator.initWithAllocator(allocator);
    defer iter.deinit();

    // Skip program name.
    _ = iter.next();

    var arg_config_path: ?[]const u8 = null;
    defer if (arg_config_path) |p| allocator.free(p);

    var arg_variant_unresolved: ?UnresolvedVariant = null;

    var is_daemon: bool = false;

    while (iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "--config")) {
            if (arg_config_path) |_| {
                std.log.err("--config is already set", .{});
                return ExitCode.incorrect_usage.to_u8();
            }

            const value = iter.next() orelse {
                std.log.err("--config option requires a value", .{});
                return ExitCode.incorrect_usage.to_u8();
            };

            arg_config_path = try allocator.dupe(u8, value);
            continue;
        }

        if (std.mem.eql(u8, arg, "--verbose")) {
            log_level = .debug;
            continue;
        }

        if (std.mem.eql(u8, arg, "--daemon")) {
            is_daemon = true;
            continue;
        }

        if (arg_variant_unresolved) |_| {
            std.log.err("Variant is already set (reading \"{s}\")", .{arg});
            return ExitCode.incorrect_usage.to_u8();
        }

        arg_variant_unresolved = UnresolvedVariant.fromString(arg) catch {
            std.log.err("Unknown variant \"{s}\".", .{arg});
            return ExitCode.incorrect_usage.to_u8();
        };
    }

    const variant_unresolved = arg_variant_unresolved orelse {
        std.log.err("Variant is required", .{});
        return ExitCode.incorrect_usage.to_u8();
    };

    if (is_daemon and variant_unresolved != .auto) {
        std.log.err("--daemon option is only available for \"auto\" variant", .{});
        return ExitCode.incorrect_usage.to_u8();
    }

    switch (variant_unresolved) {
        .auto => {
            if (arg_config_path) |config_path| {
                const file = std.fs.cwd().openFile(config_path, .{}) catch |err| {
                    std.log.err("Unable to open config file at {s}: {s}", .{ config_path, @errorName(err) });
                    return ExitCode.generic_error.to_u8();
                };
                defer file.close();

                var config_reader = std.json.reader(allocator, file.reader());
                defer config_reader.deinit();
                const config = std.json.parseFromTokenSource(Config, allocator, &config_reader, .{}) catch |err| {
                    std.log.err("Unable to parse config file at {s}: {s}", .{ config_path, @errorName(err) });
                    return ExitCode.generic_error.to_u8();
                };
                defer config.deinit();

                if (is_daemon) {
                    while (true) {
                        const current = sunwait.poll(allocator, config.value.location) catch |err| {
                            std.log.err("Failed to get current suntime: {s}", .{@errorName(err)});
                            return ExitCode.generic_error.to_u8();
                        };
                        _ = apply(allocator, current.toVariant());

                        sunwait.wait(allocator, config.value.location) catch |err| {
                            std.log.err("Failed to wait for suntime event: {s}", .{@errorName(err)});
                            return ExitCode.generic_error.to_u8();
                        };
                    }
                }

                const current = sunwait.poll(allocator, config.value.location) catch |err| {
                    std.log.err("Failed to get current suntime: {s}", .{@errorName(err)});
                    return ExitCode.generic_error.to_u8();
                };

                return apply(allocator, current.toVariant()).to_u8();
            }

            const variant = Variant.fromTime() catch |err| {
                std.log.err("Unable to resolve variant: {s}", .{@errorName(err)});
                return ExitCode.generic_error.to_u8();
            };

            return apply(allocator, variant).to_u8();
        },
        .manual => |variant| {
            return apply(allocator, variant).to_u8();
        },
    }
}

test {
    _ = @import("./variant.zig");
}
