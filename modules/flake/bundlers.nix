{
  config,
  lib,
  inputs,
  ...
}:
let
  partition = "schemas";

  coreInputs = inputs.core.inputs;

  partitionedInputs = config.partitions.${partition}.extraInputs;

  flake = {
    imports = [
      coreInputs.flake-parts.flakeModules.bundlers
    ];

    config = {
      flake.schemas = {
        inherit (partitionedInputs.flake-schemas.exportedSchemas) bundlers;
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.transposition ];

  meta = {
    description = "Bundlers for flake-parts";
    shortDescription = "Bundlers for flake-parts";
  };
}
