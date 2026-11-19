<!-- owner: Automata | zone: technical | purpose: Canonical technical index for devlib, the devenv-based Nix flake module collection -->
# Devlib

A collection of Nix flake modules that bootstrap a consistent, reproducible
developer experience using `devenv`, `git-hooks`, and `treefmt`. It provides
declarative generators for common workflows and config files, exported from a
single flake whose `flake.nix` wires the `devenv`, `flake-parts`, and `git-hooks`
inputs.

## Flake exports

- `devenvModule` &mdash; enables all integrated generators (gitignore, GitHub
  workflows, sops, &hellip;)
- `devenvModules.<name>` &mdash; opinionated, composable devenv profiles
- `homeModule` / `homeModules.<name>` &mdash; Home Manager modules for tooling
  and shell config
- `flakeModule` &mdash; flake-parts module routing `treefmt` and `pre-commit`
  from a chosen `devenv.shell`

## Devenv profiles

Import profiles into a shell, e.g. `inputs.devlib.devenvModules.git`, `.nix`,
or `.shell`. Available: `docker`, `elixir`, `git`, `go`, `javascript`, `nix`,
`ocaml`, `opentofu`, `python`, `rust`, `skaffold`, `shell`, `texlive`, `yaml`.
Preconfigured shells: `shikanime`, `shikanime-studio`. Most profiles import a
shared `base.nix` that enables formatting, Git hooks, and generators.

Enter a shell with `nix develop` or `direnv allow` (the repo ships `.envrc`).

## Generators

Generators write config into the consuming repo. Enable them under the shell
config, then run the install task:

```bash
devenv tasks run devlib:github:workflows:install
```

Integrations live under `modules/devenv/integrations/`: `github` (workflow
generation, with per-workflow submodules), `gitignore`, `sops`, and tool
integrations (`air`, `buf`, `ghstack`). The generated Skaffold workflow is
`workflow_call` + `workflow_dispatch` with `push` and `otel-endpoint` inputs;
the `skaffold` profile adds `skaffold` and `fluxcd`.

## Home Manager

Modules under `modules/home/` cover `base`, `nix`, `shell`, `vcs`, `unix`,
`k8s`, `docker`, `go`, `javascript`, `python`, `rust`, `elixir`, `typst`, and
`yaml` formatting. Import e.g. `inputs.devlib.homeModules.vcs`.

## Flake module

Add `inputs.devlib.flakeModule` and configure `devlib.devenv`,
`devlib.git-hooks`, and `devlib.treefmt` to select a source shell and route its
settings into top-level `treefmt` and `pre-commit` outputs.

## Templates

- `nix flake init -t github:shikanime-labs/devlib#default` &mdash; project scaffold
- `nix flake init -t github:shikanime-labs/devlib#remote` &mdash; remote direnv setup

## Repository conventions

- Commits: plain-text capitalized title, no conventional-commit prefix.
- Nix: dotted assignment for a single leaf; a record literal once two or more
  keys share a parent, with keys sorted.
- Markdown: wrap at 80 columns. Run `nix fmt` and `nix flake check` before
  shipping.

## Repository layout

- `modules/devenv/profiles/` &mdash; one module per devenv profile
- `modules/devenv/integrations/` &mdash; generators and tool integrations
- `modules/devenv/shells/` &mdash; preconfigured `shikanime` shells
- `modules/home/` &mdash; Home Manager modules
- `modules/flake/default.nix` &mdash; the flake-parts `flakeModule`
- `templates/` &mdash; flake templates (`default`, `remote`)
- `flake.nix` / `flake.lock` &mdash; flake entry point and pinned inputs
- `docs/` &mdash; this canonical index

## Canonical sources

- [Repository README](https://github.com/shikanime-labs/devlib#readme)
- [Technical wiki](https://github.com/shikanime-labs/devlib/wiki)
  ([Architecture](https://github.com/shikanime-labs/devlib/wiki/Architecture),
  [Operations](https://github.com/shikanime-labs/devlib/wiki/Operations))

In-repo `docs/` is canonical for technical detail; the wiki is a rendered human
index that links here.
