local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  implementation = local.inputs.core.inputs.flake-parts.flakeModules.easyOverlay;
in
{
  flake.components = {
    nixology.extra.easyOverlay = {
      inherit implementation;

      dependencies = [
        nixology.flake.overlays
      ];

      meta = {
        description = "Expose the upstream flake-parts easyOverlay module as a nixology component.";
        shortDescription = "easy overlay management";
      };
    };
  };
}
