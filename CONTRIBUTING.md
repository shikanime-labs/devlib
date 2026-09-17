# Contributing to devlib

Collection of development modules

## Workflow

Fork, branch off `main`, open a PR against `main`. One logical change per PR.

## Environment

```sh
direnv allow  # or: nix develop
```

## Validation

`nix flake check` green before submitting.

Security issues: see [SECURITY.md](SECURITY.md).
