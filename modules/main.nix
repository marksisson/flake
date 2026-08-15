{ inputs, ... }:
let
  inherit (inputs.core.lib.components) implementationsOf;
in
{
  imports =
    with inputs.core.components;
    implementationsOf [
      nixology.core.components
      nixology.core.lib
      nixology.core.partitions
      nixology.extra.touchup
    ];
}
