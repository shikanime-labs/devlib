# Devlib

A collection of Nix flake modules that bootstrap a consistent, reproducible
developer experience using `devenv`, `git-hooks`, and `treefmt`.

**Language:** Nix

## Structure

- `flake.nix` — Main flake exposing all modules
- `modules/` — Nix module definitions (devenv profiles, home-manager modules)
- `README.md` — Documentation and quick start guide

## Commit Style

- Plain-text capitalized title, no conventional-commit prefix
- Body with labels: `Design:`, `Related:`, `Closes #`
- Keep Markdown lines wrapped at 80 columns and run `nix fmt` before shipping

## Protect `main`

- Require 1 approving review
- Require linear history (no merge commits)
- Require signed commits
- Squash+rebase merge only

_Licensed under Apache-2.0. Test modules with `nix flake check` before
submitting. Maintain backward compatibility with existing consumer flakes_
