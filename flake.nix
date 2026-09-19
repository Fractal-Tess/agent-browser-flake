{
  description = "agent-browser packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      packageFor = system: nixpkgs.legacyPackages.${system}.callPackage ./packages/agent-browser.nix { };
    in
    {
      packages = forAllSystems (
        system:
        let
          agent-browser = packageFor system;
        in
        {
          inherit agent-browser;
          default = agent-browser;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.agent-browser}/bin/agent-browser";
          meta.description = "Run agent-browser";
        };
      });

      checks = forAllSystems (system: {
        agent-browser = self.packages.${system}.agent-browser;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      overlays.default = final: _previous: {
        agent-browser = final.callPackage ./packages/agent-browser.nix { };
      };

      nixosModules.default = import ./modules/nixos.nix { inherit self; };
      homeManagerModules.default = import ./modules/home-manager.nix { inherit self; };
    };
}
