<!-- owner: shikanime | zone: internal | purpose: exported modules -->
# Reference

## Exported flake outputs

- `devenvModule` — all-in-one generator module.
- `devenvModules.<name>` — profiles: `base`, `default`, `git`, `go`,
  `javascript`, `nix`, `rust`, `docker`, `elixir`, `ocaml`, `shell`, …
- `homeModule` / `homeModules.<name>` — Home Manager modules.
- `flakeModule` — flake-parts module (treefmt + pre-commit).

## Integrations

`air`, `buf`, `ghstack`, `github` (cleanup/commands/integration/javascript/
nix/release/skaffold/triage), `gitignore`, `license`, `renovate`, `sops`.

## Templates

- `templates.default` — `AGENTS.md` + `flake.nix` for a new repo.
- `templates.remote` — remote-scaffold variant.
