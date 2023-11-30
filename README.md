# Zephyr Project - Development Environment

This Nix Flake allows use of Zephyr SDK by applications in a reproducible way. It offers following
features:

* Selection of toolchains to install, reducing the download size.
* Allow addition of extra packages inside the development shell.
* Provide a fully reproducible Python environment with Zephyr SDK requirements.

## Quickstart

To use the development shell, you can use a flake such as:

```nix
{
  inputs.nixpkgs.url = "nixpkgs/23.11";

  inputs.zephyr-rtos = {
    url = "github:katyo/zephyr-rtos.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, zephyr-rtos, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ zephyr-rtos.overlays.default ];
      });
    in
    {
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkZephyrSdk { };
      });
    };
}
```

Once this is done, the `nix develop` command will get you under a development shell ready for Zephyr
Project development.

## Templates

- `all-toolchains`: using all supported toolchains
- `arm`: using arm toolchain

## Packages

- `openocd-svd`
- `openocd-zephyr`
- `renode`
- `uncrustify_0_72`
- `zephyr-sdk`
