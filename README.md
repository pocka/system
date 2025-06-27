<!--
Copyright 2023 Shota FUJI <pockawoooh@gmail.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.

SPDX-License-Identifier: 0BSD
-->

# pocka/system

My systems configuration using Nix/Home Manager.

![Screenshot of the configured Wayland desktop](./screenshot.png)

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

### Display changes between Home Manager generations

First, find the directory that contains Nix profiles.
For defaults location, see this page: <https://nix.dev/manual/nix/2.18/command-ref/files/profiles>.

Then, run `nix profile diff-closures --profile <profiles directory>/home-manager`.

## Requirements

### `dev-linux`

Due to each softwares' design limitation, the system needs to have these packages.

- [niri](https://github.com/YaLTeR/niri)
- [`pantheon-polkit-agent`](https://archlinux.org/packages/extra/x86_64/pantheon-polkit-agent/) ... The one installed installed using Nix cannot lookup `polkit-agent-helper-1`.
- [swaylock](https://github.com/swaywm/swaylock) ... access to PAM required, which is not possible with regular user Nix installation.

A custom Swaybar module assumes Markdown file placed at `$XDG_DATA_HOME/todo.md`.
Create a symbolic link or normal file there (module tries to read in 10s interval if the file does not exist.)

## Programs

### `hm-clean`

`hm-clean` removes obsolete Home Manager generations.

```sh
# Clean obsolete home-manager generations.
hm-clean

# with verbose logging.
hm-clean --verbose
```

## License

This project is compliant with [REUSE specification](https://reuse.software/).
Commentable files have copyright and license header and uncommentable files (e.g. binary, JSON) have an adjacent text file named `<filename>.license`.

- Files under `programs/` are licensed under [Apache-2.0](./LICENSES/Apache-2.0.txt).
- Media files are licensed under [CC BY-ND 4.0](./LICENSES/CC-BY-ND-4.0.txt).
- Files under `vendor/` are licensed differently: see each files' license header or adjacent `.license` file.
- Other files, including Nix config files, are licensed under [Zero-Clause BSD](./LICENSES/0BSD.txt).
