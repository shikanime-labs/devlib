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

## Stack Workflow

- Install the official GitHub extension once: `gh extension install github/gh-stack`
  (requires GitHub CLI ≥ 2.0; `gh stack` is in public preview and may change).
- Keep one logical change per PR; split large work into a stack of PRs.
- Create a stack: `gh stack init`, then `gh stack add` for each new branch, and
  commit on the active branch. `gh stack view` lists the stack.
- Submit/update: `gh stack submit` (add `--open` to open PRs, `--auto` to skip
  prompts). Resubmit after each change to refresh titles, bodies, and branches.
- Pull down an existing stack: `gh stack checkout <PR_NUMBER>` (also accepts a
  stack number, PR URL, or branch name).
- Rebase onto updated trunk: `gh stack rebase` (cascading), then `gh stack submit`.
- Land a stack: `gh stack merge` (interactive) or
  `gh stack merge <PR_NUMBER> --yes --squash` to merge up to a PR.
- Never `gh pr merge` on a stacked PR — only `gh stack merge` lands stacks.
- Never force-push stack branches; `gh stack` owns the branch pointers.
