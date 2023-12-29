{ pkgs }:
rec {
  openocd-zephyr = pkgs.callPackage ./openocd-zephyr { };

  zephyr-sdk = pkgs.callPackage ./zephyr-sdk-ng {
    overrideOpenocd = openocd-zephyr;
  };

  openocd-svd = pkgs.callPackage ./openocd-svd { };

  uncrustify_0_72 = pkgs.callPackage ./uncrustify-0.72 { };
}
