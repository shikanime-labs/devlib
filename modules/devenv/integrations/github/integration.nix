{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.github.workflows.integration;
in
{
  options.github.workflows.integration = {
    enable = mkEnableOption "integration workflow";
  };

  config = mkIf cfg.enable {
    github.settings.workflows.integration = {
      name = "Integration";
      on.workflow_dispatch = { };
      on.workflow_call.secrets = {
        OPERATOR_PRIVATE_KEY.required = true;
        CACHIX_AUTH_TOKEN.required = false;
      };
      on.pull_request = {
        branches = [
          "main"
          "gh/*/*/base"
        ];
        types = [
          "opened"
          "reopened"
          "synchronize"
          "ready_for_review"
        ];
      };
      on.merge_group.types = [ "checks_requested" ];
      permissions.contents = "read";
    };
  };
}
