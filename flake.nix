{
  description = "Flake settings for Nix develop, dualsubgen";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
  let
      supportedSystems = [
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in
  {
    devShells = forAllSystems (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      default = pkgs.mkShell {
        packages = with pkgs; [
          python313
          python313Packages.openai-whisper
          python313Packages.googletrans
        ];

        shellHook = ''
          echo "Hello Nix develop for dualsubgen"
        '';
      };
    });
  };
}
