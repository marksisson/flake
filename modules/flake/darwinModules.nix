{
  inputs,
  lib,
  config,
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
      flake.darwinModules = mkOption {
        type = lazyAttrsOf deferredModule;

        default = { };

        apply = mapAttrs (
          name: module: {
            _class = "darwin";
            _file = "${moduleLocation}#darwinModules.${name}";
            imports = [ module ];
          }
        );

        description = ''
          Darwin modules.

          Use this for reusable Darwin configuration, service modules, and
          other nix-darwin modules.
        '';

        example = literalExpression ''
          {
            configuration = { pkgs, ... }: {
              environment.systemPackages = [
                pkgs.vim
                pkgs.wget
              ];

              programs.zsh.enable = true;
            };
          }
        '';
      };
    };

    config = {
      flake.schemas = {
        inherit (partitionedInputs.flake-schemas.exportedSchemas) darwinModules;
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Provide reusable nix-darwin modules through the `darwinModules` flake output.";
    shortDescription = "darwin modules";
  };
}
