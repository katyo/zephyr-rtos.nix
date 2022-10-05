{ pkgs ? import <nixpkgs> {}, ... }:
pkgs.extend (self: super: with self; rec {
  zephyr-openocd = callPackage ./zephyr-openocd.nix {};

  zephyr-sdk = callPackage ./zephyr-sdk-ng.nix {
    overrideOpenocd = zephyr-openocd;
  };

  openocd-svd = callPackage ./openocd-svd.nix {};

  renode = callPackage ./renode.nix {};

  uncrustify_0_72 = callPackage ./uncrustify-0.72.nix {};
})
