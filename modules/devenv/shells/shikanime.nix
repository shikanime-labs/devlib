{ lib, ... }:

with lib;

let
  cachixName = "shikanime";
  cachixPublicKey = "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts=";
in
{
  containers = mkForce { };

  github = {
    enable = true;
    workflows = {
      commands.enable = true;
      integration.enable = true;
      release.enable = true;

      nix.cachix-name = cachixName;
      nix.cachix-public-key = cachixPublicKey;

      skaffold.enable = true;
      skaffold.settings.setup-nix = {
        cachix-name = cachixName;
        extra-config = ''
          extra-substituters = https://${cachixName}.cachix.org
          extra-trusted-public-keys = ${cachixPublicKey}
        '';
      };
    };

    settings.workflows.integration.jobs.nix."with"."cachix-name" = cachixName;
    settings.workflows.release.jobs.nix."with"."cachix-name" = cachixName;
  };
}
