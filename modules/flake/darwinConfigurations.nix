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
      flake.darwinConfigurations = mkOption {
        type = lazyAttrsOf raw;

        default = { };

        description = ''
          Instantiated Darwin configurations. Used by `darwin-rebuild`.

          `darwinConfigurations` is for specific machines. For reusable
          configurations, expose modules through `darwinModules` instead.
        '';

        example = literalExpression ''
          {
            my-machine = inputs.nix-darwin.lib.darwinSystem {
              modules = [ ./configuration.nix ];
              specialArgs = { inherit inputs; };
            };
          }
        '';
      };
    };

    config = {
      flake.schemas = {
        inherit (partitionedInputs.flake-schemas.exportedSchemas) darwinConfigurations;
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Provide instantiated Darwin configurations for `darwin-rebuild`.";
    shortDescription = "darwin configurations";
  };
}
