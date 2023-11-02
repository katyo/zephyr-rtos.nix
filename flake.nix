{
  description = "Zephyr Project - Development Environment";

  inputs.nixpkgs.url = "nixpkgs/23.05";

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });
    in
    {
      overlays.default = import ./overlay;

      templates = {
        all-toolchains = {
          path = ./templates/all-toolchains;
          description = "Zephyr Project template, using all supported toolchains";
        };

        arm = {
          path = ./templates/arm;
          description = "Zephyr Project template, using arm toolchain";
        };
      };

      packages = forAllSystems (system: import ./pkgs { pkgs = nixpkgsFor.${system}; });

      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkZephyrSdk { };
      });
    };
}
