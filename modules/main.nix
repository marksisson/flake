{ inputs, ... }:
let
  inherit (inputs) core;

  inherit (core.components) nixology;
  inherit (core.lib.components) uses;
in
uses {
  components = [
    nixology.core.components
    nixology.core.lib
    nixology.core.partitions
    nixology.extra.touchup
  ];
}
