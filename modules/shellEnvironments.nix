{
  partitions.development.module = {
    perSystem =
      { config, ... }:
      let
        inherit (config) shellEnvironments;
      in
      {
        shellEnvironments.default = shellEnvironments.nix;
      };
  };
}
