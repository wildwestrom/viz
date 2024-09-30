{
  description = "very minimal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        legacyPackages = pkgs;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
            entr
            zig
            zls
            glfw
            # wayland deps
            wayland
            wayland-scanner
            libxkbcommon
            # X11 deps
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXinerama
            xorg.libXi
          ];
        };
      }
    );
}
