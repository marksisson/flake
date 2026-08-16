{ config, inputs, ... }:
let
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

  partition = "schemas";

  coreInputs = inputs.core.inputs;

  partitionedInputs = config.partitions.${partition}.extraInputs;

  mkPartComponent =
    name: shortDescription:
    let
      module = {
        imports = [
          "${coreInputs.flake-parts}/modules/${name}.nix"
        ];

        config.flake.schemas.${name} = partitionedInputs.flake-schemas.exportedSchemas.${name};
      };
    in
    {
      inherit module;

      dependencies = with inputs.self.components; [
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
