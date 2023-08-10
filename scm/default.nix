# SCM module: SCM/VCS tools and their configurations.
{ username
, email
, gpgKeyId ? null
,
}: { ... }: {
  imports = [
    (
      import ./git.nix {
        inherit username email gpgKeyId;
      }
    )
    ./fossil.nix
  ];
}
