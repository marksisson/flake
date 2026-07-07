{ ... }@local:
let
  inherit (local.inputs) core;
in
{
  # export core.nix components as flake.nix components
  flake.components = core.components;
}
