{ config, lib, pkgs, ... }:
let
  cfg = config.features.wayland-de.niri;

  output = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Display output name, you can obtain from `niri msg outputs`";
      };

      scale = lib.mkOption {
        type = lib.types.float;
        description = "DPI";
        default = 1.0;
      };
    };
  };

  serializeOutput = background-color: o:
    ''
      output "${o.name}" {
        scale ${builtins.toString o.scale}
        ${if background-color == null then "//no bg" else "background-color \"${background-color}\""}
      }
    '';

  serializeSpawnArg = a:
    builtins.concatStringsSep " " (builtins.map (s: "\"${s}\"") a);
in
{
  options = {
    features.wayland-de.niri = {
      enable = lib.mkEnableOption "Niri";

      outputs = lib.mkOption {
        type = lib.types.listOf output;
        default = [ ];
      };

      background-color = lib.mkOption {
        type = lib.types.nullOr lib.types.string;
        default = null;
      };

      input = {
        keyboard = {
          repeat-delay = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 200;
          };
          repeat-rate = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 25;
          };
        };
      };

      spawn-at-startup = lib.mkOption {
        type = lib.types.listOf (lib.types.listOf lib.types.nonEmptyStr);
        description = ''
          `spawn-at-startup` accepts a path to the program binary as the first argument, followed by arguments to the program.

          Note that running niri as a systemd session supports xdg-desktop-autostart out of the box, which may be more convenient to use. Thanks to this, apps that you configured to autostart in GNOME will also "just work" in niri, without any manual `spawn-at-startup` configuration.
        '';
        default = [ ];
      };

      layout = {
        gaps = lib.mkOption {
          type = lib.types.ints.unsigned;
          description = "Set gaps around windows in logical pixels.";
          default = 16;
        };

        center-focused-column = lib.mkOption {
          type = lib.types.enum [ "never" "always" "on-overflow" ];
          description = ''
            When to center a column when changing focus, options are:
            - "never", default behavior, focusing an off-screen column will keep at the left
            or right edge of the screen.
            - "always", the focused column will always be centered.
            - "on-overflow", focusing a column will center it if it doesn't fit
            together with the previously focused column.
          '';
          default = "never";
        };

        focus-ring = {
          width = lib.mkOption {
            type = lib.types.ints.unsigned;
            description = "How many logical pixels the ring extends out from the windows.";
            default = 3;
          };

          active-color = lib.mkOption {
            type = lib.types.nonEmptyStr;
            description = ''
              Color of the ring on the active monitor.

              Colors can be set in a variety of ways:
              - CSS named colors: "red"
              - RGB hex: "#rgb", "#rgba", "#rrggbb", "#rrggbbaa"
              - CSS-like notation: "rgb(255, 127, 0)", rgba(), hsl() and a few others.

              You can also use gradients. They take precedence over solid colors.
              Gradients are rendered the same as CSS linear-gradient(angle, from, to).
              The angle is the same as in linear-gradient, and is optional,
              defaulting to 180 (top-to-bottom gradient).
              You can use any CSS linear-gradient tool on the web to set these up.
              Changing the color space is also supported, check the wiki for more info.

              active-gradient from="#80c8ff" to="#bbddff" angle=45

              You can also color the gradient relative to the entire view
              of the workspace, rather than relative to just the window itself.
              To do that, set relative-to="workspace-view".

              inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
            '';
            default = "#7fc8ff";
          };

          inactive-color = lib.mkOption {
            type = lib.types.nonEmptyStr;
            description = ''
              Color of the ring on inactive monitors.

              Colors can be set in a variety of ways:
              - CSS named colors: "red"
              - RGB hex: "#rgb", "#rgba", "#rrggbb", "#rrggbbaa"
              - CSS-like notation: "rgb(255, 127, 0)", rgba(), hsl() and a few others.

              You can also use gradients. They take precedence over solid colors.
              Gradients are rendered the same as CSS linear-gradient(angle, from, to).
              The angle is the same as in linear-gradient, and is optional,
              defaulting to 180 (top-to-bottom gradient).
              You can use any CSS linear-gradient tool on the web to set these up.
              Changing the color space is also supported, check the wiki for more info.

              active-gradient from="#80c8ff" to="#bbddff" angle=45

              You can also color the gradient relative to the entire view
              of the workspace, rather than relative to just the window itself.
              To do that, set relative-to="workspace-view".

              inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
            '';
            default = "#505050";
          };
        };

        struts = {
          left = lib.mkOption {
            type = lib.types.int;
            description = ''
              Struts shrink the area occupied by windows, similarly to layer-shell panels.
              You can think of them as a kind of outer gaps. They are set in logical pixels.
              Left and right struts will cause the next window to the side to always be visible.
            '';
            default = 0;
          };

          right = lib.mkOption {
            type = lib.types.int;
            description = ''
              Struts shrink the area occupied by windows, similarly to layer-shell panels.
              You can think of them as a kind of outer gaps. They are set in logical pixels.
              Left and right struts will cause the next window to the side to always be visible.
            '';
            default = 0;
          };

          top = lib.mkOption {
            type = lib.types.int;
            description = ''
              Struts shrink the area occupied by windows, similarly to layer-shell panels.
              You can think of them as a kind of outer gaps. They are set in logical pixels.
              Top and bottom struts will simply add outer gaps in addition to the area occupied by
              layer-shell panels and regular gaps.
            '';
            default = 0;
          };

          bottom = lib.mkOption {
            type = lib.types.int;
            description = ''
              Struts shrink the area occupied by windows, similarly to layer-shell panels.
              You can think of them as a kind of outer gaps. They are set in logical pixels.
              Top and bottom struts will simply add outer gaps in addition to the area occupied by
              layer-shell panels and regular gaps.
            '';
            default = 0;
          };
        };
      };

      prefer-no-csd = lib.mkOption {
        type = lib.types.bool;
        description = ''
          Ask the clients to omit their client-side decorations if possible.
          If the client will specifically ask for CSD, the request will be honored.
          Additionally, clients will be informed that they are tiled, removing some client-side rounded corners.
          This option will also fix border/focus ring drawing behind some semitransparent windows.
          After enabling or disabling this, you need to restart the apps for this to take effect.
        '';
        default = true;
      };

      screenshot-path = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = ''
          You can change the path where screenshots are saved.
          A ~ at the front will be expanded to the home directory.
          The path is formatted with strftime(3) to give you the screenshot date and time.
        '';
        default = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      };

      window-rule-all = {
        corner-radius = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 8;
        };
      };

      hotkey-overlay = {
        skip-at-startup = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    };
  };

  config = lib.mkIf config.features.wayland-de.enable {
    xdg.configFile."niri/config.kdl" = {
      # https://github.com/YaLTeR/niri/wiki/Configuration:-Overview
      text = ''
        input {
          keyboard {
            repeat-delay ${builtins.toString cfg.input.keyboard.repeat-delay}
            repeat-rate ${builtins.toString cfg.input.keyboard.repeat-rate}
          }

          // This section includes libinput settings.
          // Omitting settings disables them, or leaves them at their default values.
          touchpad {
            natural-scroll
            accel-speed 0.2
            accel-profile "adaptive"
            scroll-method "two-finger"
            scroll-factor 0.3
            click-method "clickfinger"
          }
        }

        ${lib.strings.concatStringsSep "\n" (builtins.map (serializeOutput cfg.background-color) cfg.outputs)}

        layout {
          gaps ${builtins.toString cfg.layout.gaps}
          center-focused-column "${cfg.layout.center-focused-column}"

          preset-column-widths {
            // Proportion sets the width as a fraction of the output width, taking gaps into account.
            // For example, you can perfectly fit four windows sized "proportion 0.25" on an output.
            // The default preset widths are 1/3, 1/2 and 2/3 of the output.
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
          }

          // You can change the default width of the new windows.
          // If you leave the brackets empty, the windows themselves will decide their initial width.
          default-column-width {}

          focus-ring {
            width ${builtins.toString cfg.layout.focus-ring.width}

            active-color "${cfg.layout.focus-ring.active-color}"

            inactive-color "${cfg.layout.focus-ring.inactive-color}"
          }

          border {
            off
          }

          struts {
            left ${builtins.toString cfg.layout.struts.left}
            right ${builtins.toString cfg.layout.struts.right}
            top ${builtins.toString cfg.layout.struts.top}
            bottom ${builtins.toString cfg.layout.struts.bottom}
          }
        }

        ${if cfg.prefer-no-csd then "" else "//"}prefer-no-csd
        screenshot-path "${cfg.screenshot-path}"

        animations {
        }

        // Open the Firefox picture-in-picture player as floating by default.
        window-rule {
          // This app-id regular expression will work for both:
          // - host Firefox (app-id is "firefox")
          // - Flatpak Firefox (app-id is "org.mozilla.firefox")
          match app-id=r#"firefox$"# title="^Picture-in-Picture$"
          open-floating true
        }

        // Enable rounded corners for all windows.
        window-rule {
          geometry-corner-radius ${builtins.toString cfg.window-rule-all.corner-radius}
          clip-to-geometry true
        }

        hotkey-overlay {
          ${if cfg.hotkey-overlay.skip-at-startup then "" else "//" }skip-at-startup
        }

        ${builtins.concatStringsSep "\n" (builtins.map (a: "spawn-at-startup ${serializeSpawnArg a}") cfg.spawn-at-startup)}

        binds {
          Mod+Shift+Slash { show-hotkey-overlay; }
          Mod+T { spawn "${config.lib.nixGL.wrap pkgs.ghostty}/bin/ghostty"; }
          Mod+D { spawn "${pkgs.tofi}/bin/tofi-drun" "--drun-launch=true"; }
          Mod+X { spawn "swaylock"; }
          Mod+Q { close-window; }

          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          Mod+Ctrl+H     { move-column-left; }
          Mod+Ctrl+J     { move-window-down; }
          Mod+Ctrl+K     { move-window-up; }
          Mod+Ctrl+L     { move-column-right; }

          Mod+U              { focus-workspace-down; }
          Mod+I              { focus-workspace-up; }

          Mod+Ctrl+U         { move-column-to-workspace-down; }
          Mod+Ctrl+I         { move-column-to-workspace-up; }

          Mod+BracketLeft  { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }
          Mod+Comma  { consume-window-into-column; }
          Mod+Period { expel-window-from-column; }

          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-window-height; }
          Mod+Ctrl+R { reset-window-height; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+C { center-column; }

          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          Mod+V       { toggle-window-floating; }
          Mod+Shift+V { switch-focus-between-floating-and-tiling; }

          Mod+Shift+E { quit; }
          Ctrl+Alt+Delete { quit; }

          Mod+Shift+P { power-off-monitors; }
        }
      '';
    };
  };
}
