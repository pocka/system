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
    #compdef ${name}

    function _${name} {
      local line state

      _arguments -C \
        "--help[Output usage text to stdout]" \
        "--verbose[Enable verbose logging]" \
        "1: :->cmds" \
        "*::arg:->args"

      case "$state" in
        (cmds)
          _values "specialise command" \
            "set[Switch to a specialisation]" \
            "unset[Switch to a normal generation]" \
            "clean[Delete obsolete generations]"
        ;;
        (args)
          case $line[1] in
            (set)
              _${name}_set
            ;;
          esac
        ;;
      esac
    }

    function _${name}_set {
      local state

      _arguments -C \
        "1: :->cmds"

      case "$state" in
        (cmds)
          _values "specialisations" \
            ${if specialisations == null then "" else
              lib.strings.concatStringsSep " " specialisations
            }
        ;;
      esac
    }

    if [ "$funcstack[1]" = "_${name}" ]; then
      _${name} "$@"
    else
      compdef _${name} ${name}
    fi
    EOF)
  '';
}
