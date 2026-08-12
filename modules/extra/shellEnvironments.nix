{ inputs, lib, ... }:
let
  inherit (inputs.self.components) nixology;

  inherit (lib)
    mapAttrs
    mkIf
    mkOption
    ;

  inherit (lib.types)
    anything
    lazyAttrsOf
    lines
    listOf
    literalExpression
    package
    submodule
    ;

  inherit (inputs) core;

  inherit (core.lib.parts) mkPerSystemOption;

  implementation = {
    options = {
      perSystem = mkPerSystemOption (
        { pkgs, ... }:
        {
          options.shellEnvironments = mkOption {
            type = lazyAttrsOf (submodule {
              options = {
                inputsFrom = mkOption {
                  type = listOf package;
                  default = [ ];
                  description = "Packages whose inputs and shell hooks are included.";
                };

                mkShellOverrides = mkOption {
                  type = lazyAttrsOf anything;
                  default = { };
                  description = "Overrides applied to `pkgs.mkShell`.";
                };

                packages = mkOption {
                  type = listOf package;
                  default = [ ];
                  description = "Packages to include in the development shell.";
                };

                shellHook = mkOption {
                  type = lines;
                  default = "";
                  description = "Shell hook script run when entering the shell.";
                };

                stdenv = mkOption {
                  type = package;
                  default = pkgs.stdenvNoCC;
                  defaultText = literalExpression "pkgs.stdenvNoCC";
                  description = "The stdenv used for the development shell.";
                };
              };
            });
            default = { };
            description = "Development shell environments.";
          };
        }
      );
    };

    config = {
      perSystem =
        { config, pkgs, ... }:
        mkIf (config.shellEnvironments != { }) {
          devShells = mapAttrs (
            name: shellEnv:
            pkgs.mkShell.override shellEnv.mkShellOverrides {
              inherit name;
              inherit (shellEnv)
                inputsFrom
                packages
                shellHook
                stdenv
                ;
            }
          ) config.shellEnvironments;
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
    nixology.extra.shellEnvironments = {
      inherit implementation;

      dependencies = [
        nixology.systems.default
        nixology.flake.devShells
      ];

      meta = {
        description = "Define named development shell environments and expose them as `devShells`.";
        shortDescription = "development shell environments";
      };
    };
  };
}
