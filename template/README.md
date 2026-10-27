# Standard Development Environment Template

Bootstrap a new repository on the Shikanime developer experience: devenv
shell, formatting, Git hooks, and CI generators from
[devlib](https://github.com/shikanime-labs/devlib).

Copy this directory into a new repository root (or run
`nix flake new -t github:shikanime-labs/devlib#standard .` once the
template output exists), then:

1. `git init && git add . && git commit -m "Bootstrap from devlib template"`
2. `direnv allow`
3. Add the language profiles your project needs (see devlib README).
