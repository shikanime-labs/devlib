<!-- owner: shikanime | zone: internal | purpose: consume/release -->
# Runbook

## Consume

Add `devlib` to a flake's inputs (following `README.md`), then import
profiles into a `devenv.shell`:

```nix
perSystem = _: {
  devenv.shells.default.imports = [
    inputs.devlib.devenvModules.git
    inputs.devlib.devenvModules.nix
  ];
};
```

## Release

No published version; consumers pin a git ref. Bump the ref in the
consuming repo when a module changes.

## Branch protection

`main` is protected (1 review, linear history, signed commits). Land with
`gh stack merge`. Test modules with `nix flake check` before submitting.
