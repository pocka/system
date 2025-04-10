# Copyright 2023 Shota FUJI <pockawoooh@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# SPDX-License-Identifier: 0BSD

{ config, lib, pkgs, ... }:
let
  cfg = config.features.wayland-de.tofi;

  directionalValue = lib.types.either
    lib.types.int
    (lib.types.submodule {
      options = {
        top = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        right = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        bottom = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        left = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
      };
    });

  percentageValue = lib.types.either
    lib.types.ints.unsigned
    lib.types.nonEmptyStr;

  directionalValueToString = v:
    if lib.isInt v then
      builtins.toString v
    else
      with builtins; "${toString v.top}, ${toString v.right}, ${toString v.bottom}, ${toString v.left}";
in
{
  options = {
    features.wayland-de.tofi = {
      textCursor = lib.mkOption {
        description = "Show a text cursor in the input field.";
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };

      history = lib.mkOption {
        description = ''
          Sort results by number of usages.
          By default, this is only effective in the run and drun modes - see the history-file option for more information.
        '';
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };

      historyFile = lib.mkOption {
        description = ''
          Specify an alternate file to read and store history information from / to.
          This shouldn't normally be needed, and is intended to facilitate the creation of custom modes.
          The default value depends on the current mode.
        '';
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };

      fuzzyMatch = lib.mkOption {
        description = ''
          If true, searching is performed via a simple fuzzy matching algorithm.
          If false, substring matching is used, weighted to favour matches closer to the beginning of the string.
        '';
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };

      font = {
        family = lib.mkOption {
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        size = lib.mkOption {
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };

        variations = lib.mkOption {
          description = ''
            List of OpenType font variation settings to apply.
            The format is similar to the CSS "font-variation-settings" property.
            For example, "wght 900" will set the weight of a variable font to 900 (if supported by the chosen font).
          '';
          type = lib.types.nullOr (lib.types.listOf lib.types.nonEmptyStr);
          default = null;
        };
      };

      backgroundColor = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;
        default = null;
      };

      outline = {
        width = lib.mkOption {
          description = ''
            Width of the border outlines.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };

        color = lib.mkOption {
          description = ''
            Color of the border outlines.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };
      };

      border = {
        width = lib.mkOption {
          description = ''
            Width of the border.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };

        color = lib.mkOption {
          description = ''
            Color of the border.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };
      };

      textColor = lib.mkOption {
        description = ''
          Color of text.
        '';
        type = lib.types.nullOr lib.types.nonEmptyStr;
        default = null;
      };

      prompt = {
        text = lib.mkOption {
          description = ''
            Prompt text.
          '';
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        padding = lib.mkOption {
          description = ''
            Extra horizontal padding between prompt and input.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };

        color = lib.mkOption {
          description = ''
            Color of prompt text.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        background = lib.mkOption {
          description = ''
            Background color of prompt.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        backgroundPadding = lib.mkOption {
          description = ''
            Extra padding of the prompt background.
          '';
          type = lib.types.nullOr directionalValue;
          default = null;
        };

        backgroundCornerRadius = lib.mkOption {
          description = ''
            Corner radius of the prompt background.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };
      };

      placeholder = {
        text = lib.mkOption {
          description = ''
            Placeholder input text.
          '';
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        color = lib.mkOption {
          description = ''
            Color of placeholder input text.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        background = lib.mkOption {
          description = ''
            Background color of placeholder input text.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        backgroundPadding = lib.mkOption {
          description = ''
            Extra padding of the placeholder input text background.
          '';
          type = lib.types.nullOr directionalValue;
          default = null;
        };

        backgroundCornerRadius = lib.mkOption {
          description = ''
            Corner radius of the placeholder input text background.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };
      };

      input = {
        color = lib.mkOption {
          description = ''
            Color of input text.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        background = lib.mkOption {
          description = ''
            Background color of input text.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        backgroundPadding = lib.mkOption {
          description = ''
            Extra padding of the input text background.
          '';
          type = lib.types.nullOr directionalValue;
          default = null;
        };

        backgroundCornerRadius = lib.mkOption {
          description = ''
            Corner radius of the input text background.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };
      };

      defaultResult = {
        color = lib.mkOption {
          description = ''
            Default color of result text.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        background = lib.mkOption {
          description = ''
            Default background color of results.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        backgroundPadding = lib.mkOption {
          description = ''
            Default extra padding of result backgrounds.
          '';
          type = lib.types.nullOr directionalValue;
          default = null;
        };

        backgroundCornerRadius = lib.mkOption {
          description = ''
            Default corner radius of result backgrounds.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };
      };

      alternateResult = {
        color = lib.mkOption {
          description = ''
            Color of alternate (even-numbered) result text.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        background = lib.mkOption {
          description = ''
            Background color of alternate (even-numbered) results.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        backgroundPadding = lib.mkOption {
          description = ''
            Extra padding of alternate (even-numbered) result backgrounds.
          '';
          type = lib.types.nullOr directionalValue;
          default = null;
        };

        backgroundCornerRadius = lib.mkOption {
          description = ''
            Corner radius of alternate (even-numbered) result backgrounds.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };
      };

      numResults = lib.mkOption {
        description = ''
          Maximum number of results to display.
          If n = 0, tofi will draw as many results as it can fit in the window.
        '';
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
      };

      selection = {
        color = lib.mkOption {
          description = ''
            Color of selected result.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        matchColor = lib.mkOption {
          description = ''
            Color of the matching portion of the selected result.
            This will not always be shown if the fuzzy-match option is set to true.
            Any color that is fully transparent (alpha = 0) will disable this highlighting.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        background = lib.mkOption {
          description = ''
            Background color of selected result.
          '';
          type = lib.types.nullOr lib.types.nonEmptyStr;
          default = null;
        };

        backgroundPadding = lib.mkOption {
          description = ''
            Extra padding of the selected result background.
          '';
          type = lib.types.nullOr directionalValue;
          default = null;
        };

        backgroundCornerRadius = lib.mkOption {
          description = ''
            Corner radius of the selected result background.
          '';
          type = lib.types.nullOr lib.types.ints.unsigned;
          default = null;
        };
      };

      resultSpacing = lib.mkOption {
        description = ''
          Spacing between results. Can be negative.
        '';
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      minInputWidth = lib.mkOption {
        description = ''
          Minimum width of input in horizontal mode.
        '';
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
      };

      width = lib.mkOption {
        description = ''
          Width of the window.
        '';
        type = lib.types.nullOr percentageValue;
        default = null;
      };

      height = lib.mkOption {
        description = ''
          Height of the window.
        '';
        type = lib.types.nullOr percentageValue;
        default = null;
      };

      cornerRadius = lib.mkOption {
        description = ''
          Radius of the window corners.
        '';
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
      };

      anchor = lib.mkOption {
        description = ''
          Location on screen to anchor the window.
        '';
        type = lib.types.nullOr (lib.types.enum [
          "top-left"
          "top"
          "top-right"
          "bottom-left"
          "bottom"
          "bottom-right"
          "right"
          "left"
          "center"
        ]);
        default = null;
      };

      exclusiveZone = lib.mkOption {
        description = ''
          Set the size of the exclusive zone.
          A value of -1 means ignore exclusive zones completely.
          A value of 0 will move tofi out of the way of other windows' exclusive zones.
          A value greater than 0 will set that much space as an exclusive zone.
          Values greater than 0 are only meaningful when tofi is anchored to a single edge.
        '';
        type = lib.types.nullOr (lib.types.either lib.types.int lib.types.nonEmptyStr);
        default = null;
      };

      output = lib.mkOption {
        description = ''
          The name of the output to appear on, if multiple outputs are present.
          If empty, the compositor will choose which output to display the window on (usually the currently focused output).
        '';
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      scale = lib.mkOption {
        description = ''
          Scale the window by the output's scale factor.
        '';
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };

      margin = {
        top = lib.mkOption {
          description = ''
            Offset from top of screen.
            Only has an effect when anchored to the top of the screen.
          '';
          type = lib.types.nullOr percentageValue;
          default = null;
        };
        bottom = lib.mkOption {
          description = ''
            Offset from bottom of screen.
            Only has an effect when anchored to the bottom of the screen.
          '';
          type = lib.types.nullOr percentageValue;
          default = null;
        };
        left = lib.mkOption {
          description = ''
            Offset from left of screen.
            Only has an effect when anchored to the left of the screen.
          '';
          type = lib.types.nullOr percentageValue;
          default = null;
        };
        right = lib.mkOption {
          description = ''
            Offset from right of screen.
            Only has an effect when anchored to the right of the screen.
          '';
          type = lib.types.nullOr percentageValue;
          default = null;
        };
      };

      padding = {
        top = lib.mkOption {
          description = ''
            Padding between top border and text.
          '';
          type = lib.types.nullOr percentageValue;
          default = null;
        };
        bottom = lib.mkOption {
          description = ''
            Padding between bottom border and text.
          '';
          type = lib.types.nullOr percentageValue;
          default = null;
        };
        left = lib.mkOption {
          description = ''
            Padding between left border and text.
          '';
          type = lib.types.nullOr percentageValue;
          default = null;
        };
        right = lib.mkOption {
          description = ''
            Padding between right border and text.
          '';
          type = lib.types.nullOr percentageValue;
          default = null;
        };
      };

      clipToPadding = lib.mkOption {
        description = ''
          Whether to clip text drawing to be within the specified padding.
          This is mostly important for allowing text to be inset from the border, while still allowing text backgrounds to reach right to the edge.
        '';
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };

      horizontal = lib.mkOption {
        description = ''
          List results horizontally.
        '';
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };

      hintFont = lib.mkOption {
        description = ''
          Perform font hinting.
          Only applies when a path to a font has been specified via font.
          Disabling font hinting speeds up text rendering appreciably, but will likely look poor at small font pixel sizes.
        '';
        type = lib.types.nullOr lib.types.bool;
        default = null;
      };
    };
  };

  config = lib.mkIf config.features.wayland-de.enable {
    home.packages = with pkgs; [
      # Tiny dynamic menu for Wayland
      # https://github.com/philj56/tofi
      tofi
    ];

    xdg.configFile."tofi/config" =
      let
        quote = str: "\"${str}\"";

        map = f: x:
          if isNull x then
            null
          else
            f x;

        entries = attrset:
          lib.trivial.pipe attrset [
            (lib.attrsets.mapAttrsToList
              (name: value:
                if isNull value then
                  null
                else
                  "${name} = ${value}"
              ))
            (builtins.filter builtins.isString)
            (lib.strings.concatStringsSep "\n")
          ];
      in
      {
        text = entries {
          "text-cursor" = map lib.trivial.boolToString cfg.textCursor;
          "history" = map lib.trivial.boolToString cfg.history;
          "history-file" = cfg.historyFile;
          "fuzzy-match" = map lib.trivial.boolToString cfg.fuzzyMatch;

          "font" = map quote cfg.font.family;
          "font-size" = map builtins.toString cfg.font.size;
          "font-variation" = map (lib.strings.concatStringsSep ",") cfg.font.variations;

          "background-color" = cfg.backgroundColor;

          "outline-width" = map builtins.toString cfg.outline.width;
          "outline-color" = cfg.outline.color;

          "text-color" = cfg.textColor;

          "border-width" = map builtins.toString cfg.border.width;
          "border-color" = cfg.border.color;

          "prompt-text" = map quote cfg.prompt.text;
          "prompt-padding" = map builtins.toString cfg.prompt.padding;
          "prompt-color" = cfg.prompt.color;
          "prompt-background" = cfg.prompt.background;
          "prompt-background-padding" = map directionalValueToString cfg.prompt.backgroundPadding;
          "prompt-background-corner-radius" = map lib.trivial.boolToString cfg.prompt.backgroundCornerRadius;

          "placeholder-text" = cfg.placeholder.text;
          "placeholder-color" = cfg.placeholder.color;
          "placeholder-background" = cfg.placeholder.background;
          "placeholder-background-padding" = map directionalValueToString cfg.placeholder.backgroundPadding;
          "placeholder-background-corner-radius" = map builtins.toString cfg.placeholder.backgroundCornerRadius;

          "input-color" = cfg.input.color;
          "input-background" = cfg.input.background;
          "input-background-padding" = map directionalValueToString cfg.input.backgroundPadding;
          "input-background-corner-radius" = map builtins.toString cfg.input.backgroundCornerRadius;

          "default-result-color" = cfg.defaultResult.color;
          "default-result-background" = cfg.defaultResult.background;
          "default-result-background-padding" = map directionalValueToString cfg.defaultResult.backgroundPadding;
          "default-result-background-corner-radius" = map builtins.toString cfg.defaultResult.backgroundCornerRadius;

          "alternate-result-color" = cfg.alternateResult.color;
          "alternate-result-background" = cfg.alternateResult.background;
          "alternate-result-background-padding" = map directionalValueToString cfg.alternateResult.backgroundPadding;
          "alternate-result-background-corner-radius" = map builtins.toString cfg.alternateResult.backgroundCornerRadius;

          "num-results" = map builtins.toString cfg.numResults;

          "selection-color" = cfg.selection.color;
          "selection-match-color" = cfg.selection.matchColor;
          "selection-background" = cfg.selection.background;
          "selection-background-padding" = map directionalValueToString cfg.selection.backgroundPadding;
          "selection-background-corner-radius" = map builtins.toString cfg.selection.backgroundCornerRadius;

          "result-spacing" = map builtins.toString cfg.resultSpacing;

          "min-input-width" = map builtins.toString cfg.minInputWidth;

          "width" = map builtins.toString cfg.width;
          "height" = map builtins.toString cfg.height;
          "corner-radius" = map builtins.toString cfg.cornerRadius;
          "anchor" = cfg.anchor;
          "exclusive-zone" = map builtins.toString cfg.exclusiveZone;
          "output" = cfg.output;
          "scale" = map lib.trivial.boolToString cfg.scale;

          "margin-top" = map builtins.toString cfg.margin.top;
          "margin-bottom" = map builtins.toString cfg.margin.bottom;
          "margin-left" = map builtins.toString cfg.margin.left;
          "margin-right" = map builtins.toString cfg.margin.right;

          "padding-top" = map builtins.toString cfg.padding.top;
          "padding-bottom" = map builtins.toString cfg.padding.bottom;
          "padding-left" = map builtins.toString cfg.padding.left;
          "padding-right" = map builtins.toString cfg.padding.right;

          "clip-to-padding" = map lib.trivial.boolToString cfg.clipToPadding;
          "horizontal" = map lib.trivial.boolToString cfg.horizontal;
          "hint-font" = map lib.trivial.boolToString cfg.hintFont;
        };
      };
  };
}

