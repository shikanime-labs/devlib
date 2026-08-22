{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.renovate;

  jsonFormat = pkgs.formats.json { };

  # Renovate renamed these fields (renovatebot config migrations). Wrap bare
  # regex patterns in /.../ delimiters on the way out so the generated config
  # stays valid without consumers having to update their flake.
  # ponytail: covers only fileMatch/matchPackagePatterns renames from PR1732; extend here when Renovate deprecates more.
  migrateSettings =
    settings:
    let
      wrap = p: "/${p}/";

      flux' =
        if settings ? flux && settings.flux ? fileMatch then
          removeAttrs settings.flux [ "fileMatch" ]
          // {
            managerFilePatterns = map wrap settings.flux.fileMatch;
          }
        else
          settings.flux or { };

      packageRules' = map (
        rule:
        if rule ? matchPackagePatterns then
          removeAttrs rule [ "matchPackagePatterns" ]
          // {
            matchPackageNames = map wrap rule.matchPackagePatterns;
          }
        else
          rule
      ) (settings.packageRules or [ ]);

      base = removeAttrs settings [
        "flux"
        "packageRules"
      ];
    in
    base
    // optionalAttrs (flux' != { }) { flux = flux'; }
    // optionalAttrs (settings ? packageRules) { packageRules = packageRules'; };

  settings = migrateSettings cfg.settings // {
    "$schema" = "https://docs.renovatebot.com/renovate-schema.json";
  };

  configFile = jsonFormat.generate "config.json" settings;
in
{
  options.renovate = mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "enable renovate";

        settings = mkOption {
          type = types.submodule {
            freeformType = jsonFormat.type;
          };
          default = { };
          description = "Renovate settings";
        };
      };
    };

    default = { };

    description = ''
      Renovate configuration.
    '';
  };

  config = mkIf cfg.enable {
    tasks."devlib:renovate:install" = {
      description = "Install renovate configuration";
      exec =
        if config.github.enable then
          ''
            mkdir -p "${config.env.DEVENV_ROOT}/.github"
            cat ${configFile} > "${config.env.DEVENV_ROOT}/.github/renovate.json"
          ''
        else
          ''
            cat ${configFile} > "${config.env.DEVENV_ROOT}/renovate.json"
          '';
    };
  };
}
