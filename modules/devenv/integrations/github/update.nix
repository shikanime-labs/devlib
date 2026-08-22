{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.github.workflows.update;

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.github.workflows.update = {
    enable = mkEnableOption "update";

    settings = {
      checkout = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for checkout 'with' section";
      };
      create-github-app-token = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token 'with' section";
      };
      stale = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for stale 'with' section";
      };
    };
  };

  config = mkIf config.github.workflows.update.enable {
    github.settings.workflows.update = {
      jobs = {
        stale = {
          runs-on = "ubuntu-slim";
          steps = [
            {
              id = "createGithubAppToken";
              uses = "actions/create-github-app-token@v3";
              "with" = {
                client-id = "\${{ vars.OPERATOR_APP_CLIENT_ID }}";
                private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                permission-issues = "write";
                permission-pull-requests = "write";
              }
              // cfg.settings.create-github-app-token;
            }
            {
              uses = "actions/stale@v11";
              "with" = {
                days-before-close = 14;
                days-before-stale = 30;
                repo-token = "\${{ steps.createGithubAppToken.outputs.token }}";
                stale-issue-label = "stale";
                stale-pr-label = "stale";
              }
              // cfg.settings.stale;
            }
          ];
        };
      };
      name = "Update";
      on = {
        schedule = [
          { cron = "0 4 * * 0"; }
        ];
        workflow_dispatch = { };
      };
      permissions.contents = "read";
    };
  };
}
