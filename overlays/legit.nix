final: prev:
{
  legit-web = prev.legit-web.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "pocka";
      repo = "legit";
      rev = "d38d10b2cc8867e68b08d2ad19aabcbfabe9df74";
      hash = "sha256-13rv3rPr10OYmBePTu5V1499lF8r1/6NTEC02o7Tc2k=";
    };

    vendorHash = "sha256-QxkMxO8uzBCC3oMSWjdVsbR2cluYMx5OOKTgaNOLHxc=";
  });
}

