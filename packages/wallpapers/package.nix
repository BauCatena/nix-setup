{
  lib,
  stdenvNoCC,
  ...
}:
let
  # Recursively collect all regular files under `dir`, returning their
  # absolute paths (as strings, relative-joined) below `root`.
  findImages =
    root:
    let
      go =
        dir:
        let
          entries = builtins.readDir dir;
        in
        lib.concatMap (
          name:
          let
            path = dir + "/${name}";
            type = entries.${name};
          in
          if type == "directory" then
            go path
          else if type == "regular" && lib.any (ext: lib.hasSuffix ext name) [
            ".png"
            ".jpg"
            ".jpeg"
            ".webp"
          ] then
            [ path ]
          else
            [ ]
        ) (builtins.attrNames entries);
    in
    go root;

  images = findImages ./assets;

  mkWallpaper =
    name: src:
    stdenvNoCC.mkDerivation {
      inherit name src;
      dontUnpack = true;
      installPhase = /* bash */ ''
        cp $src $out
      '';
      passthru.fileName = baseNameOf src;
    };

  getFileNameWithoutExtension =
    filePath:
    let
      baseName = baseNameOf filePath;
      splitName = lib.splitString "." baseName;
    in
    if lib.length splitName > 1 then lib.concatStringsSep "." (lib.init splitName) else baseName;

  names = map getFileNameWithoutExtension images;

  wallpapers = lib.attrsets.mergeAttrsList (
    map (
      image:
      let
        name = getFileNameWithoutExtension image;
      in
      {
        "${name}" = mkWallpaper name image;
      }
    ) images
  );
in
stdenvNoCC.mkDerivation {
  name = "bautinix.wallpapers";
  src = ./assets;

  installPhase = /* bash */ ''
    mkdir -p $out/share/wallpapers
    cp -r . "$out/share/wallpapers/"
    find "$out/share/wallpapers" -name "LICENSE" -delete
  '';

  passthru = {
    updateScript = null;
    inherit names;
  }
  // wallpapers;
}
