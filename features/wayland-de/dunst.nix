{ config, lib, pkgs, ... }: {
  services =
    lib.mkIf config.features.wayland-de.enable {
      dunst = {
        enable = true;

        settings = {
          global = {
            follow = "keyboard";

            mouse_left_click = "do_action";
            mouse_middle_click = "close_current";
            mouse_right_click = "context";
          };
        };
      };
    };
}

