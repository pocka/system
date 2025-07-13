# Copyright 2025 Shota FUJI <pockawoooh@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# SPDX-License-Identifier: 0BSD

{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.features.scm-server;
in
{
  options = {
    features.scm-server = {
      enable = lib.mkEnableOption "SCMServer";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.soft-serve
      pkgs.legit-web
    ];

    xdg.dataFile."soft-serve/config.yaml" =
      let
        sshPort = "23231";
        sshDomain = "git.pocka.jp";
        httpPort = "23232";
        httpURL = "https://git.pocka.jp";
      in
      {
        text = ''
          name: "git.pocka.jp"

          log_format: "text"

          ssh:
            listen_addr: ":${sshPort}"
            public_url: "ssh://${sshDomain}:${sshPort}"
            max_timeout: 0
            idle_timeout: 120

          http:
            listen_addr: ":${httpPort}"
            public_url: "${httpURL}"

          git:
            enabled: false

          db:
            driver: "sqlite"
            data_source: "soft-serve.db?_pragma=busy_timeout(5000)&_pragma=foreign_keys(1)"

          lfs:
            enabled: false

          jobs:
            mirror_pull: "@every 30m"
        '';
      };

    systemd.user.services.soft-serve = {
      Unit = {
        Description = "Soft Serve, SSH TUI git server.";
      };

      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = 1;
        ExecStart = "${pkgs.soft-serve}/bin/soft serve";
        Environment = "SOFT_SERVE_DATA_PATH=${config.xdg.dataHome}/soft-serve";
        WorkingDirectory = "${config.xdg.dataHome}/soft-serve";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    xdg.configFile."legit/config.yaml" = {
      # TODO: Remove `readme` once created `README.md` in forked legit.
      text = ''
        repo:
          scanPath: "${config.xdg.dataHome}/soft-serve/repos/x"
          readme:
            - "readme"
            - "README"
            - "README.md"
            - "README.adoc"
            - "README.txt"
            - "ABOUT"
            - "ABOUT.md"
            - "ABOUT.adoc"
            - "ABOUT.txt"
          mainBranch:
            - "master"
            - "main"

        dirs:
          templates: "${pkgs.legit-web}/lib/legit/templates"
          static: "${pkgs.legit-web}/lib/legit/static"

        meta:
          title: "git.pocka.jp"
          description: "My personal projects"
          syntaxHighlight: true

        server:
          name: "git.pocka.jp"
          host: "127.0.0.1"
          port: 5555
      '';
    };

    systemd.user.services.legit = {
      Unit = {
        Description = "legit, web frontend for git repositories.";
      };

      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = 1;
        ExecStart = "${pkgs.legit-web}/bin/legit --config=${config.xdg.configHome}/legit/config.yaml";
        Environment = "PATH=$PATH:${lib.makeBinPath [ pkgs.git ]}";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
