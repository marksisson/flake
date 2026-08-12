{ lib, ... }:
let
  inherit (lib) genAttrs;

  development =
    let
      partition = "development";
    in
    {
      partitionedAttrs = genAttrs [ "checks" "devShells" "formatter" ] (_: partition);
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  schemas =
    let
      partition = "schemas";
    in
    {
      partitionedAttrs = genAttrs [ "schemas" ] (_: partition);
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };
in
{
  imports = [
    development
    schemas
  ];
}
