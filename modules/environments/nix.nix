{ inputs, lib, ... }:
let
  module = {
    perSystem =
      { config, pkgs, ... }:
      {
        shellEnvironments.nix.packages = [
          pkgs.nix-output-monitor
        ];

        treefmt.programs = {
          nixfmt.enable = lib.mkDefault true;
          deadnix.enable = lib.mkDefault true;
          zizmor.enable = lib.mkDefault true;

          nixf-diagnose = {
            enable = lib.mkDefault true;
            excludes = lib.mkDefault [
              config.treefmt.projectRootFile
            ];
          };

          yamlfmt = {
            enable = lib.mkDefault true;
            settings.formatter = {
              type = "basic";
              retain_line_breaks = true;
              trim_trailing_whitespace = true;
            };
          };
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
    nixology.environments.nix = {
      inherit module;

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
