{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (inputs.self.components) nixology;
  inherit (config.partitions.development.extraInputs) git-hooks;
  inherit (lib) mkIf;

  implementation = {
    imports = [
      git-hooks.flakeModule
    ];

    perSystem =
      { config, ... }:
      let
        cfg = config.pre-commit;
      in
      {
        shellEnvironments.default = mkIf (cfg.settings.enabledPackages != [ ]) {
          packages = cfg.settings.enabledPackages;
          shellHook = cfg.shellHook;
        };
      };
  };

  partitionedImplementation = {
    partitions.development.module = implementation;
  };
in
{
  imports = [
    partitionedImplementation
  ];

  flake.components = {
    nixology.tools.git-hooks = {
      inherit implementation;

      dependencies = [
        nixology.extra.shellEnvironments
        nixology.systems.default
      ];

      meta = {
        description = "Integrate git-hooks.nix pre-commit hooks with the default development shell.";
        shortDescription = "git hooks tooling";
      };
    };
  };
}
