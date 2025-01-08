{ pkgs, installShellFiles, lib, buildGoModule }:
buildGoModule rec {
  name = "hm-clean";

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
        "--verbose[Enable verbose logging]"
    }

    if [ "$funcstack[1]" = "_${name}" ]; then
      _${name} "$@"
    else
      compdef _${name} ${name}
    fi
    EOF)
  '';
}
