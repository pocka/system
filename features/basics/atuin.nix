{ config, pkgs, ... }: {
  programs = {
    # Replacement for a shell history which records additional commands context
    atuin = {
      enable = true;

      enableBashIntegration = false;
      enableFishIntegration = false;

      enableNushellIntegration = true;
      enableZshIntegration = true;

      settings = {
        auto_sync = false;

        show_preview = true;

        keymap_mode = "vim-normal";

        filter_mode = "directory";

        filter_mode_shell_up_key_binding = "session";

        update_check = false;
      };
    };
  };
}
