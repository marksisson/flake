{ inputs, lib, ... }: {
  imports =
    with inputs.core.components;
    lib.components.implementationsFrom [
      nixology.core.components
      nixology.core.lib
      nixology.core.partitions
      nixology.extra.touchup
    ];
}
