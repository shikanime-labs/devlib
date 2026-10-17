{ pkgs, ... }:

{
  imports = [ ./base.nix ];

  github.workflows.nix.enable = true;

  git-hooks.hooks.flake-checker.enable = true;

  gitignore.templates = [ "repo:shikanime-labs/gitignore/refs/heads/main/Devenv.gitignore" ];

  languages.nix.enable = true;

  renovate.settings.nix.enabled = true;

  treefmt.config.settings.formatter.nix-spacing = {
    command = pkgs.writers.writePython3Bin "nix-spacing" { } ''
      import sys

      for path in sys.argv[1:]:
          lines = open(path).read().split("\n")
          out = []
          for i, line in enumerate(lines):
              out.append(line)
              nxt = lines[i + 1] if i + 1 < len(lines) else ""
              if not line or line[0].isspace() or not nxt.strip():
                  continue
              if line.endswith(":"):
                  out.append("")
              elif line.startswith("with ") and line.endswith(";") and nxt == "let":
                  out.append("")
          open(path, "w").write("\n".join(out))
    '';
    includes = [ "*.nix" ];
  };

  treefmt.config.programs = {
    deadnix.enable = true;
    nixfmt = {
      enable = true;
      strict = true;
    };
    statix.enable = true;
  };
}
