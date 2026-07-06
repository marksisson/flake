{
  partitions.development.module = {
    perSystem =
      { ... }@module:
      {
        shellEnvironments.default = module.config.shellEnvironments.nix;
      };
  };
}
