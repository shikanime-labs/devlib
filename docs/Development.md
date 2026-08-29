<!-- owner: shikanime | zone: internal | purpose: local check loop -->
# Development

## Prerequisites

- Nix (flakes) and `direnv` — `direnv allow`.

## Local loop

```bash
direnv allow
nix flake check     # evaluate every module/system
nix fmt             # treefmt over Nix/Markdown
```

## How to add a module

1. Add a `.nix` under `modules/devenv/integrations` or `profiles`.
2. Export it from `flake.nix` (e.g. `devenvModules.<name>`).
3. Run `nix flake check`; add a consumer test if it touches outputs.
4. `nix fmt`, then open a PR (stack workflow in `AGENTS.md`).
