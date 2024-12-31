{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.features.gui.enable {
    programs.ghostty = {
      enable = true;

      package = pkgs.ghostty;

      settings = {
        font-size = 14;
        font-family = "Monaspace Neon Var";
        font-style = "Medium";
        font-style-bold = "Bold";
        font-style-italic = "Medium Italic";
        font-style-bold-italic = "Bold Italic";
        font-feature = "calt";

        copy-on-select = false;
      };

      keybindings = {
        "ctrl+shift+t" = "new_tab";
        "ctrl+shift+n" = "new_split:right";
        "ctrl+shift+m" = "new_split:down";

        "super+shift+k" = "resize_split:up,10";
        "super+shift+h" = "resize_split:left,10";
        "super+shift+j" = "resize_split:down,10";
        "super+shift+l" = "resize_split:right,10";

        "ctrl+shift+k" = "goto_split:top";
        "ctrl+shift+h" = "goto_split:left";
        "ctrl+shift+j" = "goto_split:bottom";
        "ctrl+shift+l" = "goto_split:right";
      };
    };
  };
}
