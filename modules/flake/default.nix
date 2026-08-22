_:
{
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.devlib;
in
{
  options.devlib = {
    devenv.enable = mkEnableOption "devenv" // {
      default = inputs.devenv != null;
    };

    git-hooks = {
      enable = mkEnableOption "git-hooks" // {
        default = inputs.git-hooks != null;
      };

      shell = mkOption {
        type = types.str;
        default = "default";
        description = "The shell package to use for git-hooks and treefmt";
      };
    };

    treefmt = {
      enable = mkEnableOption "Treefmt" // {
        default = inputs.treefmt-nix != null;
      };

      shell = mkOption {
        type = types.str;
        default = "default";
        description = "The shell package to use for treefmt";
      };
    };
  };

  config = {
    perSystem =
      { config, ... }:
      mkMerge [
        (mkIf cfg.devenv.enable {
          devenv.modules = [ ../devenv/profiles/default.nix ];
        })

        (mkIf cfg.git-hooks.enable {
          pre-commit.settings =
            if builtins.hasAttr cfg.git-hooks.shell config.devenv.shells then
              config.devenv.shells.${cfg.git-hooks.shell}.git-hooks
            else
              { };
        })

        (mkIf cfg.treefmt.enable {
          treefmt =
            if builtins.hasAttr cfg.treefmt.shell config.devenv.shells then
              config.devenv.shells.${cfg.treefmt.shell}.treefmt.config
            else
              { };
        })
      ];
  };
}
