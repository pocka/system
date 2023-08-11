# Platform specifc configurations
{ config, lib, pkgs, ... }:
{
  config = {
    # https://github.com/NixOS/nix/issues/3616
    # Every macOS updates overwrite /etc/zshrc and that breaks Nix initialisation.
    # This is a workaround for it so that I no longer need to manually edit the file.
    # https://github.com/NixOS/nix/issues/3616#issuecomment-1655785404
    programs.zsh = lib.mkIf (pkgs.stdenv.isDarwin && config.programs.zsh.enable) {
      initExtraFirst = ''
        if [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
          source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi
      '';
    };

    xdg = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
    };

    # I'm not sure this changes behaviour in a meaningful way.
    targets.genericLinux = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
    };
  };
}
