<!-- owner: shikanime | zone: internal | purpose: known Nix failures -->
# Troubleshooting

## `nix flake check` fails on a new system

Modules are evaluated per-system. A profile that assumes a tool absent on
some platform breaks `check`. Guard with `lib.optionalAttrs` / `mkIf`.

## treefmt reformats unexpectedly

`nix fmt` formats Markdown/Nix/YAML repo-wide. If CI reports drift, run
`nix fmt` locally and commit; never widen the formatter config to hide it.

## Wrong profile applied

Profiles are composed by import list, not auto-detected. A missing
`devenvModules.<lang>` means that language's tooling is absent — add it to
the shell imports.

## Consumer flake broke after bump

Devlib keeps backward compatibility with consumer flakes. If a bump breaks
yours, pin the last-known-good ref and file an issue.
