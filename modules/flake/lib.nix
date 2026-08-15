{ inputs, lib, ... }:
let
  module = {
    flake.lib = inputs.core.lib.extend (
      final: prev: {
        parts.mkFlake =
          args: module:
          prev.mkFlake args {
            imports = [
              module
            ]
            ++ (
              with inputs.self.components;
              lib.components.implementationsOf [
                nixology.flake.apps
                nixology.flake.checks
                nixology.flake.devShells
                nixology.flake.formatter
                nixology.flake.legacyPackages
                nixology.flake.nixosConfigurations
                nixology.flake.nixosModules
                nixology.flake.overlays
                nixology.flake.packages
              ]
            );
          };

        mkFlake = final.parts.mkFlake;
      }
    );
  };
in
{
  imports = [ module ];
}
