{
  description = "fixi + daisyUI + zs app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      zig-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zig = zig-overlay.packages.${system}.master;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            zig
            pkgs.zls
            pkgs.tailwindcss_4
            pkgs.watchexec
            pkgs.hugo
          ];

          shellHook = ''
            echo "App dev environment loaded"
          '';
        };
      }
    );
}
