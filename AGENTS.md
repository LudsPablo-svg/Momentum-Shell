# Repository Guidelines

## Project Structure & Module Organization

This repository configures an X11 desktop for Void Linux; it has no application source tree or automated test suite. Desktop settings live in their program directories: `i3/`, `bar/`, `picom/`, `terminal/`, `rofi/`, `notifications/`, and `gtk/`. Helper Bash scripts are in `scripts/`, the XBPS package list is `packages/packages.txt`, and `x11/xinitrc` provides the optional `startx` entry point. Wallpapers are in `wallpapers/`; setup and troubleshooting notes are in `README.md` and `docs/`.

## Build, Test, and Development Commands

There is no build step. From the repository root:

- `bash -n install.sh scripts/*.sh` checks shell syntax without running the scripts.
- `git diff --check` catches whitespace errors in pending changes.
- `i3 -C -c i3/config` checks the i3 configuration when i3 is installed.
- `./install.sh` installs the listed Void packages and creates configuration links, backing up existing targets. Run it as a normal user on Void Linux with `sudo` configured; it changes the local system and home directory.

When available, validate behavior in X11/i3 and note unperformed checks.

## Coding Style & Naming Conventions

Keep Bash scripts portable to Bash and follow the existing `set -Eeuo pipefail` pattern, four-space indentation, quoted expansions, and clear error messages. Name helper scripts descriptively in lowercase with hyphens, and keep them safe to invoke from their installed links under `~/.local/bin`. Preserve each configuration file's native syntax and existing theme values. Add XBPS package names one per line in `packages/packages.txt`; avoid implicit or wildcard package groups.

## Testing Guidelines

No test framework or coverage target is configured. Use the syntax and configuration checks above for relevant changes, then manually verify key bindings, launcher, status bar, notifications, and helper scripts when the target environment is available. Do not claim runtime validation from syntax checks alone.

## Commit & Pull Request Guidelines

The repository has no commit history yet, so no established commit convention is available. Use a short imperative subject, optionally scoped by area, such as `i3: adjust workspace bindings`. Describe user-visible changes and validation in pull requests; include screenshots for visual changes and note relevant Void/X11 limitations.

## Configuration Safety

Keep machine-specific secrets and personal paths out of tracked files. Before changing installer behavior, account for its backups, symlinks, and `sudo xbps-install` side effects; document any new package or destination in `README.md`.
