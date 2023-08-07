# pocka/system

My systems configuration using Nix/Home Manager.

## Usage

1. Run `nix-shell`
2. Inside the spawned shell, run `home-manager switch --flake .#<name>`
3. Exit the shell

See [`flake.nix#outputs.homeConfiguration`](./flake.nix) for a list of `<name>`s.
