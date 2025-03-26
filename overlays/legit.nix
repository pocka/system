final: prev:
{
  legit-web = prev.legit-web.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "pocka";
      repo = "legit";
      rev = "5e6eb22bac88b3cc074da553b9ab181f5f06ee3b";
      hash = "sha256-zR/FhaLlfWwWDc1mAFhxj3nz1QnXfUvyx3y/fo9Esws=";
    };

    vendorHash = "sha256-QxkMxO8uzBCC3oMSWjdVsbR2cluYMx5OOKTgaNOLHxc=";
  });
}

