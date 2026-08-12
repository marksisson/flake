{ inputs, lib, ... }:
let
  inherit (lib) mkDefault;

  implementation = {
    perSystem =
      { config, pkgs, ... }:
      {
        shellEnvironments.nix.packages = [
          pkgs.nix-output-monitor
        ];

        treefmt.programs = {
          nixfmt.enable = mkDefault true;
          deadnix.enable = mkDefault true;
          zizmor.enable = mkDefault true;

          nixf-diagnose = {
            enable = mkDefault true;
            excludes = mkDefault [
              config.treefmt.projectRootFile
            ];
          };

          yamlfmt = {
            enable = mkDefault true;
            settings.formatter = {
              type = "basic";
              retain_line_breaks = true;
              trim_trailing_whitespace = true;
            };
          };
        };
      };
  };

  partitionedImplementation = {
    partitions.development = {
      module = implementation;
    };
  };
in
{
  imports = [
    partitionedImplementation
  ];

  flake.components = {
    nixology.environments.nix = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.extra.shellEnvironments
        nixology.tools.treefmt
      ];

      meta = {
        description = "Provide a Nix development environment with formatting and diagnostic tools.";
        shortDescription = "Nix development environment";
      };
    };
  };
}
