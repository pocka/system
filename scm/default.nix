# SCM module: SCM/VCS tools and their configurations.
{
  username,
  email,
}: {...}: {
  imports = [
    (
      import ./git.nix {
        inherit username email;
      }
    )
    ./fossil.nix
  ];
}
