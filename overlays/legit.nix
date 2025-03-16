final: prev:
{
  legit-web = prev.legit-web.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "pocka";
      repo = "legit";
      rev = "130a23376beeff94e9704f2f603ee59c743cc099";
      hash = "sha256-BnplaJU/lJXOrf3juTM6mx8co58LjYKUIOvOP/1irMQ=";
    };

    vendorHash = "sha256-QxkMxO8uzBCC3oMSWjdVsbR2cluYMx5OOKTgaNOLHxc=";
  });
}

