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
      overlays = {
        default = final: prev: {
          mkZephyrSdk =
            { toolchains ? "all"
            , inputs ? [ ]
            }:
            import ./shell.nix {
              inherit toolchains inputs;
              pkgs = (import ./packages.nix { pkgs = prev; });
            };
        };
      };

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkZephyrSdk { };
        });
    };
}
