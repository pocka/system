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

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dark_mode_start = b.option(
        []const u8,
        "dark-mode-start",
        "Wall clock time dark mode starts at (hh:mm).",
    ) orelse "18:00";

    const dark_mode_end = b.option(
        []const u8,
        "dark-mode-end",
        "Wall clock time dark mode ends at (hh:mm).",
    ) orelse "08:00";

    const tzdir = b.option(
        []const u8,
        "tzdir",
        "Path to a zoneinfo directory, used when $TZDIR is not set.",
    );

    const config = b.addOptions();
    config.addOption([]const u8, "dark_mode_start", dark_mode_start);
    config.addOption([]const u8, "dark_mode_end", dark_mode_end);
    config.addOption(
        ?[:0]const u8,
        "tzdir",
        if (tzdir) |slice| try b.allocator.dupeZ(u8, slice) else null,
    );

    const exe = b.addExecutable(.{
        .name = ",theme",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addOptions("config", config);

    exe.linkLibC();
    exe.linkSystemLibrary2("gobject-2.0", .{});
    exe.linkSystemLibrary2("gio-2.0", .{});

    b.installArtifact(exe);

    // zig build run
    {
        const step = b.step("run", "Compile and Run program");

        const run = b.addRunArtifact(exe);
        if (b.args) |args| {
            run.addArgs(args);
        }

        step.dependOn(&run.step);
    }

    // zig build test
    {
        const step = b.step("test", "Run unit tests");

        const t = b.addTest(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        t.linkLibC();

        const run = b.addRunArtifact(t);

        step.dependOn(&run.step);
    }
}
