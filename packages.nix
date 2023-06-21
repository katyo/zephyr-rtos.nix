{ pkgs ? import <nixpkgs> {}, ... }:
with (import ./utils.nix { inherit (pkgs) lib; });
pkgs.extend (self: super: with self; rec {
  zephyr-openocd = (callPackage ./openocd.nix {}).overrideDerivation (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook ];
    patches = filesFromDir isPatchFile ./openocd-zephyr;
  });

  zephyr-sdk = callPackage ./zephyr-sdk-ng.nix {
    overrideOpenocd = zephyr-openocd;
  };

  openocd-svd = callPackage ./openocd-svd.nix {};

  renode = callPackage ./renode.nix {};

  uncrustify_0_72 = callPackage ./uncrustify-0.72.nix {};
})
