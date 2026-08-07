{ ... }@local:
let
  inherit (local.inputs) core self;

  inherit (self.components) nixology;

  inherit (core.lib.components) uses;
in
{
  flake.lib = core.lib.extend (
    final: _prev: {
      parts.mkFlake =
        args: module:
        final.mkFlake args {
          imports = [
            module
          ]
          ++ [
            (uses {
              components = [
                nixology.flake.apps
                nixology.flake.checks
                nixology.flake.devShells
                nixology.flake.formatter
                nixology.flake.legacyPackages
                nixology.flake.nixosConfigurations
                nixology.flake.nixosModules
                nixology.flake.overlays
                nixology.flake.packages
              ];
            })
          ];
        };

      resuableModules =
        {
          flakeref,
          name,
          modules,
        }:
        {
          imports = [ nixology.flake.modules.module ];
          flake.modules = builtins.mapAttrs (class: module: {
            ${name} = {
              key = "${flakeref}#components.${name}";
              imports = [ module ];
              _class = class;
            };
          }) modules;
        };
    }
  );
}
