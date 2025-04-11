final: prev:
{
  legit-web = prev.legit-web.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "pocka";
      repo = "legit";
      rev = "4efb241ddac7291f99416c8fa3165a1e55725283";
      hash = "sha256-ClkRPcM0AnSEVgkDrEo3/IzVyT8Bfb40dnCnDN3O0Y0=";
    };

    vendorHash = "sha256-QxkMxO8uzBCC3oMSWjdVsbR2cluYMx5OOKTgaNOLHxc=";
  });
}

