{ lib, ... }: with lib;
{
  containers = mkForce { };

  github = {
    enable = true;
    workflows = {
      commands.enable = true;
      integration.enable = true;
      release.enable = true;
    };

    settings.workflows.integration.jobs.nix."with"."cachix-name" = "shikanime-studio";
    settings.workflows.release.jobs.nix."with"."cachix-name" = "shikanime-studio";
  };
}
