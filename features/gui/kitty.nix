# The fast, feature-rich, GPU based terminal emulator
# https://sw.kovidgoyal.net/kitty/
{ config, lib, ... }:
{
  config = {
    programs =
      let
      in
      {
        kitty = lib.mkIf config.features.gui.enable {
          enable = lib.mkDefault true;

          font = {
            name = "Dank Mono";
            size = 16;
          };

          # Kitty's customisability is top-notch.
          keybindings = {
            "kitty_mod+t" = "new_tab_with_cwd";
            "kitty_mod+n" = "new_window_with_cwd";

            "kitty_mod+r" = "start_resizing_window";
            "kitty_mod+s" = "swap_with_window";
            "kitty_mod+f" = "focus_visible_window";

            "kitty_mod+k" = "neighboring_window top";
            "kitty_mod+h" = "neighboring_window left";
            "kitty_mod+j" = "neighboring_window down";
            "kitty_mod+l" = "neighboring_window right";

            "kitty_mod+a" = "next_layout";
          };

          settings = {
            # Bell
            enable_audio_bell = false;

            # Background
            background_opacity = "0.9";

            # Layouts
            enabled_layouts = "fat,tall,grid,horizontal,vertical,splits";

            # Tabs
            tab_bar_edge = "top";
            tab_bar_style = "powerline";
          };

          shellIntegration = {
            enableBashIntegration = true;
            enableZshIntegration = true;
          };
        };
      };
  };
}
