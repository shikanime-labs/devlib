{
  lib,
  pkgs,
  ...
}:
with lib; let
  jsonFormat = pkgs.formats.json {};

  configFile = jsonFormat.generate ".oxfmtrc.json" {
    printWidth = 80;
    proseWrap = "always";
  };
in {
  imports = [./default.nix];

  git-hooks.hooks.trufflehog.enable = true;

  gitignore = {
    enable = true;
    content = [".pre-commit-config.yaml"];
  };

  renovate.settings = {
    extends = [
      "config:best-practices"
      "security:openssf-scorecard"
    ];
    postUpgradeTasks = {
      commands = ["nix fmt"];
      fileFilters = ["**/*.nix"];
      executionMode = "branch";
      installTools.nix = {};
    };
  };

  treefmt = {
    enable = true;
    config = {
      programs = {
        autocorrect.enable = true;
        oxfmt.enable = true;
        rumdl-check.enable = true;
        xmllint.enable = true;
      };
      settings = {
        # NOTE: the dyff `--restructure` formatters were removed from this
        # treefmt config. `dyff --restructure` rewrites YAML by
        # reordering/restructuring keys, which wraps GitHub Actions `${{ }}`
        # expressions into invalid multi-line YAML and dirties the tree,
        # failing the `git-hooks:run` CI step on `main`. The repo's YAML is
        # prettier-formatted; dyff restructure is unsafe for Actions files.
        formatter.oxfmt = {
          includes = [
            "*.toml"
          ];
          options = [
            "--config"
            (toString configFile)
          ];
        };
        global.excludes = [
          ".devenv/*"
          ".direnv/*"
          "*.assetsignore"
          "*.dockerignore"
          "*.gcloudignore"
          "*.gif"
          "*.ico"
          "*.jpg"
          "*.png"
          "*.svg"
          "*.txt"
          "*.webp"
        ];
      };
    };
  };
}
