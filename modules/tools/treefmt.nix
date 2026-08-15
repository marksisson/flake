{ config, inputs, ... }:
let
  module = config.partitions.development.extraInputs.treefmt.flakeModule;

  partitionedModule = {
    partitions.development = { inherit module; };
  };
in
{
  imports = [ partitionedModule ];

  flake.components = {
    nixology.tools.treefmt = {
      inherit module;

      dependencies = with inputs.self.components; [
        nixology.extra.shellEnvironments
        nixology.flake.checks
        nixology.flake.formatter
        nixology.systems.default
      ];

      meta = {
        description = "Integrate treefmt-nix formatting checks and formatter outputs.";
        shortDescription = "treefmt tooling";
      };
    };
  };
}
