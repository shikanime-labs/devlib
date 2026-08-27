{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.github.workflows.pin;

  yamlFormat = pkgs.formats.yaml { };

  pinAction =
    action:
    let
      pin = cfg.pin.${action};
    in
    if pin != null then
      action + "@" + pin + " # v" + builtins.replaceAll "@" "" pin
    else
      action;

  applyPinsToSteps = workflow: {
    jobs = mapAttrs (jobName: job: {
      steps = mapAttrs (stepName: step: {
        # Only pin steps that use external actions.
        # Internal actions (e.g. `uses: ./.github/workflows/nix.yaml`) get no pin.
        # Regular runs (e.g. `run: ...`) get no pin.
        # Id-only steps (e.g. `id: direnv` without `uses`) get no pin.
        uses = lib.mkForce (pinAction step.uses);
      }) job.steps or [ ];
    }) workflow.jobs or { };
  };

  configFiles = mapAttrs (
    name: workflow:
    yamlFormat.generate "${name}.yaml" (applyPinsToSteps workflow)
  ) cfg.settings.workflows;

  zizmorConfigFile = yamlFormat.generate "zizmor.yml" {
    rules = {
      artipacked.disable = true;
      secrets-outside-env.disable = true;
      unpinned-uses.disable = true;
    };
  };
in
{
  options.github.workflows.pin = {
    enable = mkEnableOption "strategic merge pinning for workflow actions";

    pin = mkOption {
      description = "Right-biased merge overrides applied to uses: references during workflow generation. Key: action identity (e.g. \"actions/create-github-app-token@v3\"). Value: full digest (e.g. \"bcd2ba49218906704ab6c1aa796996da409d3eb1\"). When an entry exists for an action identity, the generated uses: field gets the SHA-pinned annotation (e.g. \"actions/create-github-app-token@bcd2ba49218906704ab6c1aa796996da409d3eb1 # v3\") instead of the plain semantic version tag.";
      type = types.attrsOf types.str;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    # When pins are enabled, the workflow settings are already pre-processed
    # with pin annotations applied to all uses: fields, and configFiles
    # contains the final YAML with pins. We inject the generated files and
    # treefmt config here.
    packages = [ config.github.package ];

    tasks."devlib:github:workflows:install" = {
      description = "Install GitHub Actions workflow files";
      exec = concatStringsSep "\n" (
        mapAttrsToList (name: workflow: ''
          mkdir -p "${config.env.DEVENV_ROOT}/.github/workflows"
          cat ${workflow} > "${config.env.DEVENV_ROOT}/.github/workflows/${name}.yaml"
        '') configFiles
      );
    };

    treefmt.config.programs = {
      zizmor = {
        enable = true;
        includes = [
          ".github/workflows/*.yml"
          ".github/workflows/*.yaml"
          ".github/actions/**/*.yml"
          ".github/actions/**/*.yaml"
          "**/action.yml"
          "**/action.yaml"
        ];
      };
    };

    treefmt.config.settings.formatter.zizmor.options = [
      "--config"
      "${zizmorConfigFile}"
    ];
  };
}
