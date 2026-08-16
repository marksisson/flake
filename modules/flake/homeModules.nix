{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkOption
    ;

  inherit (lib.types)
    lazyAttrsOf
    deferredModule
    literalExpression
    ;

  partition = "schemas";

  partitionedInputs = config.partitions.${partition}.extraInputs;

  moduleLocation = "${inputs.self.outPath}/flake.nix";

  flake = {
    options = {
      flake.homeModules = mkOption {
        type = lazyAttrsOf deferredModule;

        default = { };

        apply = mapAttrs (
          name: module: {
            _class = "home";
            _file = "${moduleLocation}#homeModules.${name}";
            imports = [ module ];
          }
        );

        description = ''
          Home Manager modules.

          Use this for reusable Home Manager configuration, service modules, and
          other home-manager modules.
        '';

        example = literalExpression ''
          {
            bash = { pkgs, ... }: {
              programs.bash = {
                enable = true;
                shellAliases.ll = "ls -l";
              };

              home.packages = [ pkgs.hello ];
            };
          }
        '';
      };
    };

    config = {
      flake.schemas = {
        inherit (partitionedInputs.flake-schemas.exportedSchemas) homeModules;
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Provide reusable Home Manager modules through the `homeModules` flake output.";
    shortDescription = "home manager modules";
  };
}
