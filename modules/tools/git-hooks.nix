{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.partitions.development.extraInputs) git-hooks;

  module = {
    imports = [
      git-hooks.flakeModule
    ];

    perSystem =
      { config, ... }:
      let
        cfg = config.pre-commit;
      in
      {
        shellEnvironments.default = lib.mkIf (cfg.settings.enabledPackages != [ ]) {
          packages = cfg.settings.enabledPackages;
          shellHook = cfg.shellHook;
        };
      };
  };

  partitionedModule = {
    partitions.development = { inherit module; };
  };
in
{
  imports = [ partitionedModule ];

  flake.components = {
    nixology.tools.git-hooks = {
      inherit module;

      dependencies = with inputs.self.components; [
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
