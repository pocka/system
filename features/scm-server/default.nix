{ pkgs, lib, config, ... }:
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
  };
}
