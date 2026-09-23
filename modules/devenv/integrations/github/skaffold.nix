{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.github.workflows.skaffold;

  yamlFormat = pkgs.formats.yaml { };

  githubToken = "\${{ steps.createGithubAppToken.outputs.token || secrets.GITHUB_TOKEN }}";
in
{
  options.github.workflows.skaffold = {
    enable = mkEnableOption "skaffold";

    settings = {
      checkout = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for checkout";
      };
      create-github-app-token = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for create-github-app-token";
      };
      direnv = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for direnv";
      };
      setup-nix = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for setup-nix";
      };
      integration = mkOption {
        type = types.submodule { freeformType = yamlFormat.type; };
        default = { };
        description = "Overrides for skaffold integration";
      };

      otel-endpoint = mkOption {
        type = types.str;
        default = "";
        description = "OTLP collector endpoint for tracing, e.g. localhost:4317";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      github.settings.workflows.skaffold = {
        name = "Skaffold";
        on = {
          workflow_call = {
            secrets.OPERATOR_PRIVATE_KEY.required = true;
            inputs.push = {
              type = "boolean";
              default = true;
              description = "Whether to push images during build";
            };
          };
          workflow_dispatch = { };
        };

        permissions.contents = "read";

        jobs = {
          build-render = {
            name = "Build & Render";
            runs-on = "ubuntu-latest";
            permissions = {
              contents = "read";
              packages = "write";
            };
            steps = [
              {
                continue-on-error = true;
                id = "createGithubAppToken";
                uses = "actions/create-github-app-token@v3";
                "with" = {
                  client-id = "\${{ vars.OPERATOR_APP_CLIENT_ID }}";
                  private-key = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
                  permission-contents = "read";
                }
                // cfg.settings.create-github-app-token;
              }
              {
                uses = "shikanime-labs/actions/checkout@v9";
                "with" = {
                  github-token = githubToken;
                }
                // cfg.settings.checkout;
              }
              {
                uses = "docker/login-action@v4";
                "with" = {
                  registry = "ghcr.io";
                  username = "\${{ github.actor }}";
                  password = "\${{ secrets.GITHUB_TOKEN }}";
                };
              }
              {
                uses = "shikanime-labs/actions/nix/setup@v9";
                "with" = {
                  github-token = githubToken;
                }
                // cfg.settings.setup-nix;
              }
              (
                {
                  id = "direnv";
                  uses = "shikanime-labs/actions/direnv@v9";
                }
                // optionalAttrs (cfg.settings.direnv != { }) { "with" = cfg.settings.direnv; }
              )
              {
                id = "flux-integration";
                "if" = "\${{ inputs.push }}";
                uses = "shikanime-labs/actions/flux/flux-integration@v9";
              }
              {
                id = "skaffold";
                uses = "shikanime-labs/actions/skaffold/integration@v9";
                "if" = "\${{ inputs.push != 'true' }}";
                "with" = {
                  push = "\${{ inputs.push }}";
                  otel-endpoint = "\${{ inputs.otel-endpoint }}";
                }
                // optionalAttrs (cfg.settings.integration != { }) {
                  "with" = cfg.settings.integration;
                };
              }
            ];
          };
        };
      };
    })

    (mkIf (cfg.enable && config.github.workflows.integration.enable) {
      github.settings.workflows.integration = {
        jobs = {
          skaffold = {
            "if" =
              "\${{ github.event_name == 'workflow_call' || github.event_name == 'workflow_dispatch' || (github.event.pull_request.draft == false && github.event.pull_request.head.repo.fork == false) }}";
            uses = "$/.github/workflows/skaffold.yaml";
            "with".push = false;
            permissions = {
              contents = "read";
              packages = "write";
            };
            secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          };
        };
        on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = mkDefault true;
      };
    })

    (mkIf (cfg.enable && config.github.workflows.release.enable) {
      github.settings.workflows.release = {
        jobs = {
          skaffold = {
            uses = "$/.github/workflows/skaffold.yaml";
            permissions = {
              contents = "read";
              packages = "write";
            };
            secrets.OPERATOR_PRIVATE_KEY = "\${{ secrets.OPERATOR_PRIVATE_KEY }}";
          };

          release.needs = [ "skaffold" ];
        };
        on.workflow_call.secrets.OPERATOR_PRIVATE_KEY.required = mkDefault true;
      };
    })
  ];
}
