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

const gio = @cImport({
    @cInclude("gio/gio.h");
});

const gobject = @cImport({
    @cInclude("glib-object.h");
});

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
    FailedToWriteGSettings,
};

pub fn apply(variant: Variant) ApplyError!void {
    const gnome_color_scheme = GnomeColorScheme.from_variant(variant);

    const gsettings = gio.g_settings_new("org.gnome.desktop.interface");
    defer gobject.g_object_unref(gsettings);

    const gsettings_wrote = gio.g_settings_set_enum(
        gsettings,
        "color-scheme",
        @intFromEnum(gnome_color_scheme),
    );

    if (gsettings_wrote == 0) {
        std.log.warn(
            "Unable to set GNOME color scheme to {s}",
            .{@tagName(gnome_color_scheme)},
        );
        return ApplyError.FailedToWriteGSettings;
    }

    // https://docs.gtk.org/gio/class.Settings.html#delay-apply-mode
    // > ...these writes may not complete by the time that g_settings_set()
    // > returns; see g_settings_sync()).
    gio.g_settings_sync();

    std.log.info("Set GNOME color scheme to {s}", .{@tagName(gnome_color_scheme)});
}
