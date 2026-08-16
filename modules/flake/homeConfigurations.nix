{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption;

  inherit (lib.types)
    lazyAttrsOf
    literalExpression
    raw
    ;

  partition = "schemas";

  partitionedInputs = config.partitions.${partition}.extraInputs;

  flake = {
    options = {
      flake.homeConfigurations = mkOption {
        type = lazyAttrsOf raw;

        default = { };

        description = ''
          Instantiated Home Manager configurations. Used by `home-manager`.

          `homeConfigurations` is for specific users. For reusable
          configurations, expose modules through `homeModules` instead.
        '';

        example = literalExpression ''
          {
            alice = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
              modules = [
                inputs.self.homeModules.bash
                {
                  home.username = "alice";
                  home.homeDirectory = "/home/alice";
                  home.stateVersion = "25.11";
                }
              ];
            };
          }
        '';
      };
    };

    config = {
      flake.schemas = {
        inherit (partitionedInputs.flake-schemas.exportedSchemas) homeConfigurations;
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Provide instantiated Home Manager configurations for specific users.";
    shortDescription = "home manager configurations";
  };
}
