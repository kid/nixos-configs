{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    # nixpkgs-fmt
    gnumake
  ];
}
