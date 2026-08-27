{
  inputs = {
    devenv = {
      url = "github:cachix/devenv";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    strategic-merge = {
      url = "path:../devlib.strategic-merge";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://devenv.cachix.org"
      "https://shikanime.cachix.org"
      "https://shikanime-studio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts="
      "shikanime-studio.cachix.org-1:KxV6aDFU81wzoR9u6pF1uq0dQbUuKbodOSP8/EJHXO0="
    ];
  };

  outputs =
    inputs@{
      devenv,
      flake-parts,
      git-hooks,
      treefmt-nix,
      self,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, ... }:
      with flake-parts-lib;
      let
        defaultFlakeModule = importApply ./modules/flake/default.nix { };

        # Import the pins module from the strategic-merge input to enable
        # SHA digest pinning for GitHub Actions workflow uses:.
        strategicMergeModule = importApply ./../devlib.strategic-merge/modules/devenv/integrations/github/pins.nix { };
      in
      {
        imports = [
          defaultFlakeModule
          devenv.flakeModule
          flake-parts.flakeModules.easyOverlay
          git-hooks.flakeModule
          treefmt-nix.flakeModule
        ];

        flake = {
          devenvModule = ./modules/devenv/profiles/default.nix;
          devenvModules = {
            default = self.devenvModule;
            docker = ./modules/devenv/profiles/docker.nix;
            elixir = ./modules/devenv/profiles/elixir.nix;
            git = ./modules/devenv/profiles/git.nix;
            go = ./modules/devenv/profiles/go.nix;
            javascript = ./modules/devenv/profiles/javascript.nix;
            nix = ./modules/devenv/profiles/nix.nix;
            ocaml = ./modules/devenv/profiles/ocaml.nix;
            opentofu = ./modules/devenv/profiles/opentofu.nix;
            python = ./modules/devenv/profiles/python.nix;
            rust = ./modules/devenv/profiles/rust.nix;
            skaffold = ./modules/devenv/profiles/skaffold.nix;
            shell = ./modules/devenv/profiles/shell.nix;
            shikanime = ./modules/devenv/shells/shikanime.nix;
            shikanime-studio = ./modules/devenv/shells/shikanime-studio.nix;
            texlive = ./modules/devenv/profiles/texlive.nix;
          };

          homeModule = ./modules/home/default.nix;
          homeModules = {
            default = self.homeModule;
            docker = ./modules/home/docker.nix;
            elixir = ./modules/home/elixir.nix;
            go = ./modules/home/go.nix;
            javascript = ./modules/home/javascript.nix;
            k8s = ./modules/home/k8s.nix;
            nix = ./modules/home/nix.nix;
            python = ./modules/home/python.nix;
            rust = ./modules/home/rust.nix;
            shell = ./modules/home/shell.nix;
            typst = ./modules/home/typst.nix;
            unix = ./modules/home/unix.nix;
            vcs = ./modules/home/vcs.nix;
            yaml = ./modules/home/formats.nix;
          };

          flakeModule = defaultFlakeModule;
          flakeModules = {
            default = defaultFlakeModule;
            treefmt = treefmtFlakeModule;
          };

          templates = {
            default = {
              path = ./templates/default;
              description = "A devenv template with default settings";
            };
            remote = {
              path = ./templates/remote;
              description = "A simple direnv with remote flake";
            };
          };
        };

        perSystem = { config, ... }: {
          devenv.shells.default = {
            imports = [
              self.devenvModules.git
              self.devenvModules.nix
              self.devenvModules.shell
              self.devenvModules.shikanime-studio
              strategicMergeModule
            ];

            github.workflows.pin.enable = true;
            github.workflows.pin.pin = {
              "actions/create-github-app-token@v3" = "bcd2ba49218906704ab6c1aa796996da409d3eb1";
              "actions/stale@v11" = "4391f3da665fdf50b6810c1a66712fb9ba21aa93";
              "shikanime-labs/actions/checkout@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/cleanup@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/nix/setup@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/nix/integration@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/nix/setup-checks-jobs@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/nix/setup-packages-jobs@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/command/backport@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/command/close@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/command/land@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/command/rebase@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
              "shikanime-labs/actions/command/run@v9" = "5993d4d95befc190a14c0d143583683d203ad8d1";
            };

            license = {
              enable = true;
              holder = "Shikanime Studio";
              package = config.devenv.shells.default.license.lib.pkgs.asl20;
              year = "2025";
            };
          };
        };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
      }
    );
}
