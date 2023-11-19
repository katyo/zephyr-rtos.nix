final: prev:
{
  mkZephyrSdk = final.callPackage ./mk-zephyr-sdk { };
} // import ../pkgs { pkgs = final; }
