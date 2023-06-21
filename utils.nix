{ lib, ... }:
let
  isPatchFile = name: value: value == "regular" && (lib.hasSuffix ".patch" name);
  filesFromDir = filt: path: map (name: path + "/${name}")
    (lib.naturalSort (lib.attrNames (lib.filterAttrs filt (builtins.readDir path))));
in {
  inherit isPatchFile filesFromDir;
}
