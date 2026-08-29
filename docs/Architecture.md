<!-- owner: shikanime | zone: internal | purpose: module set and design -->
# Architecture

`devlib` exposes flake outputs consumed by other repos:

- `devenvModule` — enables all integrated generators (gitignore, GitHub
  workflows, renovate, sops, …).
- `devenvModules.<name>` — composable profiles (`git`, `nix`, `shell`,
  `go`, `javascript`, `rust`, `docker`, `elixir`, `ocaml`, …) for a
  `devenv.shell`.
- `homeModule` / `homeModules.<name>` — Home Manager modules.
- `flakeModule` — a flake-parts module exposing `treefmt` + `pre-commit`
  from a chosen `devenv.shell`.

Modules live under `modules/` (`devenv/`, `home/`, `flake/`). `devenv/`
splits into `integrations/` (air, buf, ghstack, github, gitignore, license,
renovate, sops), `profiles/` (per-language shells), and `shells/`.
`templates/` holds `default` and `remote` scaffolds (`AGENTS.md`, `flake.nix`).

## Design intent

One source of truth for dev-environment hygiene, so every shikanime repo
gets the same git-hooks, formatting, and CI wiring by importing a profile.
