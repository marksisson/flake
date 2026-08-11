{
  config,
  lib,
  inputs,
  ...
}:
let
  flake = {
    imports = [
      flake-parts.flakeModules.bundlers
    ];

    config = {
      flake.schemas = {
        inherit (flake-schemas.exportedSchemas) bundlers;
      };
    };
  };

  inherit (inputs.self.components) nixology;
  inherit (inputs.core.inputs) flake-parts;
  inherit (config.partitions.schemas.extraInputs) flake-schemas;
in
lib.mkComponent {
  name = lib.basename __curPos.file;
  modules = { inherit flake; };
  dependencies = [ nixology.core.transposition ];
}
