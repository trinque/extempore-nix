{
  description = "Extempore, the live-coding environment, built against nixpkgs' LLVM and audio libraries";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forEachSystem = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: f nixpkgs.legacyPackages.${system});
    in {
      overlays.default = final: _prev: {
        extempore = final.callPackage ./package.nix { };
      };

      packages = forEachSystem (pkgs: rec {
        extempore = pkgs.callPackage ./package.nix { };
        default = extempore;
      });

      # The package's own check phase runs upstream's CI test suite, so
      # building it is the check.
      checks = forEachSystem (pkgs: { extempore = self.packages.${pkgs.system}.extempore; });
    };
}
