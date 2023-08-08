{
  # https://github.com/NixOS/nix/issues/3616
  # Every macOS updates overwrite /etc/zshrc and that breaks Nix initialisation.
  # This is a workaround for it so that I no longer need to manually edit the file.
  # https://github.com/NixOS/nix/issues/3616#issuecomment-1655785404
  programs.zsh = {
    initExtraFirst = ''
      if [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
        source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
      fi
    '';
  };
}
