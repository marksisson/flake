{
  config,
  inputs,
  lib,
  ...
}:
let
  partition = "development";

  partitionedInputs = config.partitions.${partition}.extraInputs;

  flake = {
    imports = [ partitionedInputs.treefmt.flakeModule ];
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  dogfoodPartition = partition;

  subdomain = "tools";

  modules = { inherit flake; };

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
}
