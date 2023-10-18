final: prev:
{
  mkZephyrSdk = final.callPackage ./mk-zephyr-sdk { };

  python3 = prev.python3.override {
    packageOverrides = final: prev: {
      # See: https://github.com/NixOS/nixpkgs/pull/264438
      zcbor = final.callPackage ./python-modules/zcbor.nix { };

      # See: https://github.com/NixOS/nixpkgs/pull/264443
      imgtool = final.callPackage ./python-modules/imgtool.nix { };

      lpc-checksum = final.callPackage ./python-modules/lpc-checksum.nix { };

      # See: https://github.com/NixOS/nixpkgs/pull/264425
      junit2html = final.callPackage ./python-modules/junit2html.nix { };
    };
  };

  python3Packages = final.python3.pkgs;
} // import ../pkgs { pkgs = final; }
