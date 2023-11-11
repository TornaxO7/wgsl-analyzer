{
  inputs = {
    naersk.url = "github:nix-community/naersk";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, rust-overlay, naersk }:
    let
      system = "x86_64-linux";

      overlays = [ rust-overlay.overlays.default ];
      rust = pkgs.rust-bin.stable.latest.default;
      builder = pkgs.callPackage naersk { rustc = rust; };
      pkgs = import nixpkgs { inherit system overlays; };
    in
    rec {
      packages.default = builder.buildPackage {
        name = "wgsl-analyzer";
        src = ./.;
        cargoBuildOptions = opts: [ "-p" "wgsl_analyzer" ] ++ opts;
      };

      overlays.default = (final: prev: { wgsl-analyzer = packages.default; });

      apps.default = packages.default;
      devShell =
        pkgs.mkShell { packages = with pkgs; [ rust-analyzer rust ]; };
    };
}
