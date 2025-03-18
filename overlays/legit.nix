final: prev:
{
  legit-web = prev.legit-web.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "pocka";
      repo = "legit";
      rev = "bc147a9425e6265adca2672103c0d0b0dfcd735d";
      hash = "sha256-We3ceKWo9viSfM9C/l7CvKiwfGf8bbKvH7M6M0xU1Cg=";
    };

    vendorHash = "sha256-QxkMxO8uzBCC3oMSWjdVsbR2cluYMx5OOKTgaNOLHxc=";
  });
}

