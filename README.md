# pocka/system

My systems configuration using Nix/Home Manager.

## Usage

See `outputs.homeConfigurations` section in [`flake.nix`](./flake.nix) for available `<name>`s.

### Local install

1. Clone or Download the repository
2. Run `nix-shell`
3. Inside the spawned shell, run `home-manager switch --flake .#<name>`
4. Exit the shell

Without interactive Bash session: `nix-shell --run "home-manager switch --flake .#<name>"`.

### Remote install

This is handy and useful especially for initial bootstrap, but less reproducible compared to local installation.

1. Make sure Flakes is available on your system
2. Run `nix run home-manager/master -- switch --flake github:pocka/system#<name>`

## Requirements

### `dev-linux`

Due to each softwares' design limitation, the system needs to have these packages.

- [`sway`](https://archlinux.org/packages/extra/x86_64/sway/) ... The one installed using Nix does not launch.
- [`pantheon-polkit-agent`](https://archlinux.org/packages/extra/x86_64/pantheon-polkit-agent/) ... The one installed installed using Nix cannot lookup `polkit-agent-helper-1`.

## License

[Apache-2.0](./LICENSE)
