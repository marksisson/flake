{
  config,
  inputs,
  lib,
  ...
}:
let
  partition = "development";

  partitionedInputs = config.partitions.${partition}.extraInputs;

  flake = {
    imports = [
      partitionedInputs.git-hooks.flakeModule
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
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  dogfoodPartition = partition;

  modules = { inherit flake; };

  subdomain = "tools";

  dependencies = with inputs.self.components; [
    nixology.extra.shellEnvironments
    nixology.systems.default
  ];

  meta = {
    description = "Integrate git-hooks.nix pre-commit hooks with the default development shell.";
    shortDescription = "git hooks tooling";
  };
}
