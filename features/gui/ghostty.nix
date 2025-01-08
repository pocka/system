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

        # * "calt" ... Contextual Alternates
        #              This feature enables Monaspace's Texture healing.
        # * "dlig" ... Discretionary Ligatures
        #              This feature fucks up Japanese text rendering.
        #              Enabled by default.
        font-feature = [ "calt" "-dlig" ];

        copy-on-select = false;
      };

      keybindings = {
        "ctrl+shift+t" = "new_tab";
        "ctrl+shift+n" = "new_split:down";
        "ctrl+shift+m" = "new_split:right";

        "super+shift+k" = "resize_split:up,20";
        "super+shift+h" = "resize_split:left,20";
        "super+shift+j" = "resize_split:down,20";
        "super+shift+l" = "resize_split:right,20";

        "ctrl+shift+k" = "goto_split:top";
        "ctrl+shift+h" = "goto_split:left";
        "ctrl+shift+j" = "goto_split:bottom";
        "ctrl+shift+l" = "goto_split:right";
      };
    };
  };
}
