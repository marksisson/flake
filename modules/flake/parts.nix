{ config, inputs, ... }:
let
  inherit (inputs.self.components) nixology;
  inherit (inputs.core.inputs) flake-parts;
  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  descriptions = {
    apps = "runnable programs";
    checks = "derivations for testing evaluation of this flake";
    devShells = "development shells";
    formatter = "project formatter";
    legacyPackages = "nested attribute sets of nixpkgs packages";
    nixosConfigurations = "NixOS configurations";
    nixosModules = "NixOS modules";
    overlays = "nixpkgs overlays";
    packages = "nixpkgs packages";
  };

  mkPartComponent =
    name: shortDescription:
    let
      module = {
        imports = [
          "${flake-parts}/modules/${name}.nix"
        ];

        config.flake.schemas.${name} = flake-schemas.exportedSchemas.${name};
      };
    in
    {
      inherit module;

      dependencies = [
        nixology.core.schemas
        nixology.core.transposition
      ];

      meta = {
        description = "Provide the `${name}` flake output for ${shortDescription}.";
        inherit shortDescription;
      };
    };

  parts = builtins.mapAttrs mkPartComponent descriptions;
in
{
  imports = map (component: component.module) [
    parts.checks
    parts.devShells
    parts.formatter
  ];

  flake.components = {
    nixology.flake = parts;
  };
}
