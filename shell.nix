{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShellNoCC {
  buildInputs = with pkgs; [
    python313
    python313Packages.pip
    python313Packages.openai-whisper
    python313Packages.googletrans
  ];
}
