{ inputs, lib, ... }:
let
  inherit (inputs.core.inputs) flake-parts;

  flake = {
    imports = [
      flake-parts.flakeModules.flakeModules
    ];

    config = {
      flake.schemas = {

        flakeModules = {
          version = 1;
          doc = ''
            The `flakeModules` flake output contains flake-parts modules for use by other flakes.
          '';
          inventory = _output: {
            what = "flake-parts modules for use by other flakes";
          };
        };

      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Provide the `flakeModules` flake output for reusable flake-parts modules.";
    shortDescription = "flake-parts modules";
  };
}
