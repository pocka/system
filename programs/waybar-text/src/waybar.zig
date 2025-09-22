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

pub const ModuleOutput = struct {
    text: []const u8,
    tooltip: ?[]const u8 = null,
    class: ?[]const u8 = null,

    pub fn encode(self: *const @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
        var json_writer = std.json.Stringify{
            .writer = writer,
            .options = .{ .emit_null_optional_fields = false, .whitespace = .minified },
        };

        try json_writer.write(self);
    }
};
