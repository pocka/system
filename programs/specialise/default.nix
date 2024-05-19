{ pkgs, installShellFiles, lib, buildGoModule, specialisations ? null }:
buildGoModule rec {
  name = "specialise";

  src = ./.;

  nativeBuildInputs = [ installShellFiles ];

  vendorHash = null;

  ldflags = [
    "-X main.homeManagerPath=${pkgs.home-manager}/bin/home-manager"
  ];

  postInstall = ''
    installShellCompletion --zsh --cmd ${name} <(cat << "EOF"
    #compdef _${name} ${name}

    function _${name} {
      local line

      _arguments -C \
        "--help[Output usage text to stdout]" \
        "--verbose[Enable verbose logging]" \
        "1: :(set unset clean)" \
        "*::arg:->args"

      case $line[1] in
        set)
          _${name}_set
        ;;
      esac
    }

    function _${name}_set {
      _arguments "1: :(${if specialisations == null then "" else
        lib.strings.concatStringsSep " " specialisations
      })"
    }
    EOF)
  '';
}
