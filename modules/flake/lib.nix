{ ... }@local:
let
  inherit (local.inputs) core self;
  inherit (core.lib.components) uses;
  inherit (self.components) nixology;
  inherit (local.lib) all assertMsg optional;

  implementation =
    { ... }@module:
    {
      flake.lib = core.lib.extend (
        final: _prev: {
          parts.mkFlake =
            args: module:
            final.mkFlake args {
              imports = [
                module
              ]
              ++ [
                (uses {
                  components = [
                    nixology.flake.apps
                    nixology.flake.checks
                    nixology.flake.devShells
                    nixology.flake.formatter
                    nixology.flake.legacyPackages
                    nixology.flake.nixosConfigurations
                    nixology.flake.nixosModules
                    nixology.flake.overlays
                    nixology.flake.packages
                  ];
                })
              ];
            };

          mkComponent =
            nameOrSource: scope:
            {
              modules ? { },
              dependencies ? [ ],
              domain ? null,
              subdomain ? null,
            }:
            let
              inherit (scope.inputs) flake;
              inherit (scope.config) flakeref;

              componentName = flake.lib.getFileStem nameOrSource;

              flakerefComponents =
                let
                  match = builtins.match "([a-zA-Z0-9+.-]+):([^/]+)/([^/?#]+)(/([^?#]+))?(\\?.*)?" flakeref;
                in
                if match == null then
                  null
                else
                  {
                    forge = builtins.elemAt match 0;
                    owner = builtins.elemAt match 1;
                    repo = builtins.elemAt match 2;
                    ref = builtins.elemAt match 4;
                  };

              componentDomain =
                if domain != null then
                  domain
                else if flakerefComponents != null then
                  flakerefComponents.owner
                else
                  abort "Unable to determine component domain from flake reference: ${flakeref}";

              componentSubdomain =
                if subdomain != null then
                  subdomain
                else if flakerefComponents != null then
                  flake.lib.getFileStem flakerefComponents.repo
                else
                  abort "Unable to determine component subdomain from flake reference: ${flakeref}";

              featureModule = modules.flake or null;
              targetModules = removeAttrs modules [ "flake" ];

              featureTargetModules =
                if builtins.attrNames targetModules == [ ] then
                  null
                else
                  {
                    imports = [ flake.components.nixology.flake.modules.module ];
                    flake.modules = builtins.mapAttrs (class: module: {
                      ${componentName} = {
                        key = "${flakeref}#components.${componentName}";
                        imports = [ module ];
                        _class = class;
                      };
                    }) targetModules;
                  };

              implementation = {
                imports =
                  optional (featureModule != null) featureModule
                  ++ optional (featureTargetModules != null) featureTargetModules;
              };
            in
            assert assertMsg (all (name: builtins.elem name module.config.moduleClasses) (
              builtins.attrNames modules
            )) "modules contains an unsupported module class";
            {
              imports = [ implementation ];

              flake.components.${componentDomain}.${componentSubdomain}.${componentName} = {
                inherit implementation;
                dependencies = [
                  flake.components.nixology.core.flake
                ]
                ++ dependencies;
              };
            };
        }
      );
    };
in
{
  imports = [ implementation ];
}
