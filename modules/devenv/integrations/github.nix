{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.github;
  yamlFormat = pkgs.formats.yaml { };

  configFiles = mapAttrs (
    name: workflow: yamlFormat.generate "${name}.yaml" (removeAttrs workflow [ "actions" ])
  ) cfg.settings.workflows;
in
{
  imports = [
    ./github/pins.nix
    ./github/cleanup.nix
    ./github/commands.nix
    ./github/javascript.nix
    ./github/integration.nix
    ./github/nix.nix
    ./github/release.nix
    ./github/skaffold.nix
    ./github/triage.nix
    ./github/update.nix
  ];

  options.github = {
    enable = mkEnableOption "generation of GitHub Actions workflow files";

    package = mkOption {
      type = types.package;
      default = pkgs.gh;
      description = "Package to use for GitHub Actions";
    };

    settings = {
      global = {
        workflows = mkOption {
          description = "Global configuration merged into all workflows";
          type = types.submodule {
            options.actions = mkOption {
              type = types.attrsOf (
                types.submodule {
                  freeformType = yamlFormat.type;
                }
              );
              default = { };
              description = "Global actions configuration";
            };
          };
          default = { };
        };
      };
      workflows = mkOption {
        description = "Workflows configuration";
        type = types.attrsOf yamlFormat.type;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    tasks."devlib:github:workflows:install" = {
      description = "Install GitHub Actions workflow files";
      exec = concatStringsSep "\n" (
        mapAttrsToList (name: workflow: ''
          mkdir -p "${config.env.DEVENV_ROOT}/.github/workflows"
          cat ${workflow} > "${config.env.DEVENV_ROOT}/.github/workflows/${name}.yaml"
        '') configFiles
      );
    };
  };
}
