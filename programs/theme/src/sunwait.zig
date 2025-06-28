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

//! Helper functions for running "sunwait" command.
//! That program is written in plain C but contains "main" in its core file
//! so we can't use that as a library. For simplicity, this module spawns
//! "sunwait" command instead.

const std = @import("std");

const Variant = @import("./variant.zig").Variant;

pub const Error = error{
    UnexpectedExitCode,
    CommandNotFound,
    CommandInterrupted,
    CommandUnexpectedlyTerminated,
} || std.mem.Allocator.Error || std.process.Child.RunError;

pub const Location = struct {
    latitude: f64 = 0.0,
    longitude: f64 = 0.0,

    /// Caller is responsible to release returned buffer using `allocator.free`.
    fn getLatitudeArg(self: Location, allocator: std.mem.Allocator) std.mem.Allocator.Error![]const u8 {
        const dir: u8 = if (self.latitude < 0) 'S' else 'N';

        return std.fmt.allocPrint(
            allocator,
            "{d:.4}{u}",
            .{ self.latitude, dir },
        );
    }

    /// Caller is responsible to release returned buffer using `allocator.free`.
    fn getLongitudeArg(self: Location, allocator: std.mem.Allocator) std.mem.Allocator.Error![]const u8 {
        const dir: u8 = if (self.longitude < 0) 'W' else 'E';
        return std.fmt.allocPrint(
            allocator,
            "{d:.4}{u}",
            .{ self.longitude, dir },
        );
    }
};

pub const PollResult = enum {
    day,
    night,

    pub fn toVariant(self: PollResult) Variant {
        return switch (self) {
            .day => Variant.light,
            .night => Variant.dark,
        };
    }
};

pub fn poll(allocator: std.mem.Allocator, location: Location) Error!PollResult {
    std.log.debug("Getting suntime state...", .{});
    const lat_arg = try location.getLatitudeArg(allocator);
    defer allocator.free(lat_arg);

    const lon_arg = try location.getLongitudeArg(allocator);
    defer allocator.free(lon_arg);

    const run_result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &.{
            "sunwait",
            "poll",
            lat_arg,
            lon_arg,
        },
    }) catch |err| return switch (err) {
        error.FileNotFound => Error.CommandNotFound,
        else => err,
    };
    allocator.free(run_result.stderr);
    allocator.free(run_result.stdout);

    switch (run_result.term) {
        .Exited => |code| switch (code) {
            2 => return .day,
            3 => return .night,
            else => {
                std.log.warn("sunwait exited unexpectedly: exit code={d}", .{code});
                return Error.UnexpectedExitCode;
            },
        },
        .Signal => |sig| {
            std.log.warn("sunwait(signal): {d}", .{sig});
            return Error.CommandInterrupted;
        },
        else => {
            std.log.err("sunwait terminated abnormally: {s}", .{@tagName(run_result.term)});
            return Error.CommandUnexpectedlyTerminated;
        },
    }
}

/// Block the running thread until day/night changes.
pub fn wait(allocator: std.mem.Allocator, location: Location) Error!void {
    std.log.debug("Waiting suntime events...", .{});
    const lat_arg = try location.getLatitudeArg(allocator);
    defer allocator.free(lat_arg);

    const lon_arg = try location.getLongitudeArg(allocator);
    defer allocator.free(lon_arg);

    const run_result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &.{
            "sunwait",
            "wait",
            lat_arg,
            lon_arg,
        },
    }) catch |err| return switch (err) {
        error.FileNotFound => Error.CommandNotFound,
        else => err,
    };
    allocator.free(run_result.stderr);
    allocator.free(run_result.stdout);

    switch (run_result.term) {
        .Exited => |code| switch (code) {
            0 => {
                // sunwait returns incorrect result when invoked exactly at the sunrise/sunset time.
                std.log.debug("Waiting 5 seconds for accurate result...", .{});
                std.Thread.sleep(std.time.ns_per_s * 5);
                return;
            },
            else => {
                std.log.warn("sunwait exited unexpectedly: exit code={d}", .{code});
                return Error.UnexpectedExitCode;
            },
        },
        .Signal => |sig| {
            std.log.warn("sunwait(signal): {d}", .{sig});
            return Error.CommandInterrupted;
        },
        else => {
            std.log.err("sunwait terminated abnormally: {s}", .{@tagName(run_result.term)});
            return Error.CommandUnexpectedlyTerminated;
        },
    }
}
