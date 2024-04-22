# The fast, feature-rich, GPU based terminal emulator
# https://sw.kovidgoyal.net/kitty/
{ config, lib, ... }:
{
  config = {
    programs =
      {
        kitty = lib.mkIf config.features.gui.enable {
          enable = lib.mkDefault true;

          font = {
            name = "Dank Mono";
            size = 15;
          };

          # Kitty's customisability is top-notch.
          keybindings = {
            "kitty_mod+t" = "new_tab_with_cwd";
            "kitty_mod+n" = "launch --location=hsplit --cwd=current";
            "kitty_mod+m" = "launch --location=vsplit --cwd=current";

            "kitty_mod+r" = "start_resizing_window";
            "kitty_mod+s" = "swap_with_window";
            "kitty_mod+f" = "focus_visible_window";

            "kitty_mod+k" = "neighboring_window top";
            "kitty_mod+h" = "neighboring_window left";
            "kitty_mod+j" = "neighboring_window down";
            "kitty_mod+l" = "neighboring_window right";
          };

          settings = {
            font_features = "DankMono-Regular -liga";

            # Bell
            enable_audio_bell = false;

            # Layouts
            enabled_layouts = "splits";

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
