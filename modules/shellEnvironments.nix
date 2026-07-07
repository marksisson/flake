{
  partitions.development = {
    module = {
      perSystem =
        { ... }@module:
        let
          inherit (module.config) shellEnvironments;
        in
        {
          shellEnvironments.default = shellEnvironments.nix;
        };
    };
  };
}
