{ catppuccinTheme }: { pkgs
                     , lib
                     , ...
                     }: {
  programs =
    let
      # Convert the input string's first character to upper case.
      # Example: "foo" -> "Foo"
      toCapital = with lib;
        str:
        let
          len = builtins.stringLength str;
          head = strings.toUpper (builtins.substring 0 1 str);
          tail = builtins.substring 1 (len - 1) str;
        in
        head + tail;
    in
    {
      # The fast, feature-rich, GPU based terminal emulator
      # https://sw.kovidgoyal.net/kitty/
      kitty = {
        enable = true;

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

        theme = "Catppuccin-${toCapital catppuccinTheme}";
      };
    };
}
