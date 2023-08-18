# Dynamically generates a wallpaper (PNG) based on specified Catppuccin flavor.
#
# -- Why `mocha` is required?
# The `source.svg` hard-codes mocha colors.
# Mocha palette is required for replace those with specified flavor.
{ pkgs, flavor, colors, mocha, width, height }:
pkgs.stdenv.mkDerivation rec {
  version = "0.0.1";
  pname = "catppuccin-${flavor}-wallpaper";
  src = ./.;

  builtInputs = [ pkgs.resvg pkgs.replace ];

  phases = [ "buildPhase" "installPhase" ];


  # ┌─────────────────────┐
  # │Is it "mocha" flavor?│
  # └─┬───────────┬───────┘
  #   │Yes     No │
  #   │       ┌───▼─────────────────────┐
  #   │       │Replace SVG fills/strokes│
  #   │       └───┬─────────────────────┘
  #   │           │
  # ┌─▼───────────▼────────┐
  # │Render PNG using resvg│
  # └──────────────────────┘
  buildPhase = let
    # Replace mocha colors to specified flavor's colors.
    replaceColors = pkgs.lib.trivial.pipe mocha
      [ (pkgs.lib.attrsets.mapAttrsToList (
          name: value:
            let
              old = value.hex;
              new = colors.${name}.hex;
            in
              # Skip the argument if same, otherwise replace-literal exits with an error
              if old == new then
                null
              else
                "\"${value.hex}\" \"${colors.${name}.hex}\""
        ))
        (builtins.filter builtins.isString)
        (pkgs.lib.strings.concatStringsSep " -a ")
      ];

    # Skip replace-literal if there is no replace argument, otherwise it exits with an error
    replaceStep = if replaceColors == "" then
      "cp $src/source.svg wallpaper.svg"
    else
      "cat $src/source.svg | ${pkgs.replace}/bin/replace-literal ${replaceColors} > wallpaper.svg";
  in with colors; ''
    ${replaceStep}

    ${pkgs.resvg}/bin/resvg -w ${builtins.toString width} -h ${builtins.toString height} --background "${base.hex}" wallpaper.svg out.png
  '';

  installPhase = ''
    mkdir -p $out/usr/share/backgrounds
    cp out.png $out/usr/share/backgrounds/catppuccin-${flavor}.png
  '';
}
