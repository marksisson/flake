{ inputs, ... }:
let
  inherit (inputs.core.inputs) flake-parts;
  module = flake-parts.flakeModules.easyOverlay;
in
{
  flake.components = {
    nixology.extra.easyOverlay = {
      inherit module;

      dependencies = with inputs.self.components; [ nixology.flake.overlays ];

      meta = {
        description = "Expose the upstream flake-parts easyOverlay module as a nixology component.";
        shortDescription = "easy overlay management";
      };
    };
  };
}
