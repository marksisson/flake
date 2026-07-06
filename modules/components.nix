{ ... }@local:
{
  # export core.nix components as flake.nix components
  flake.components = local.inputs.core.components;
}
