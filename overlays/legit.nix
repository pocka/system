final: prev:
{
  legit-web = prev.legit-web.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "pocka";
      repo = "legit";
      rev = "31530491fbc221dec93dc9692abe2d5fcfcc67ea";
      hash = "sha256-lx4ShOkAbDJ04cVhVHDunrpX83HSYMlq9NGWRs0fuDs=";
    };

    vendorHash = "sha256-QxkMxO8uzBCC3oMSWjdVsbR2cluYMx5OOKTgaNOLHxc=";
  });
}

