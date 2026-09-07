# Repository Guidelines

## Project Structure & Module Organization
- Root-level Bash scripts implement the core behavior: `sleep`, `wakeup`, `sleeplog`, and `SleepManager.1m.sh`.
- Installer and tooling scripts live alongside the core scripts: `install.sh`, `uninstall.sh`, `diagnostic.sh`, and `test_config.sh`.
- Configuration lives in `config.template` and is written at runtime to `~/.sleepmanager.conf` by `install.sh`.
- Interactive configuration helpers are `config_editor` and `config_editor_auto`.
- `readme.md` is the primary user guide, including installation, `How to use`, configuration, SwiftBar, troubleshooting, and development checks.
- `help.md` is the Italian operational manual and must stay aligned with current commands and menu behavior.

## Build, Test, and Development Commands
- `brew install sleepwatcher` installs the dependency used to trigger sleep/wake hooks.
- `./install.sh` sets up scripts, writes `~/.sleepmanager.conf`, configures `pmset`, and registers shell aliases.
- `./MASTER_INSTALL.sh` runs the full guided install when you want the end-to-end workflow.
- `./uninstall.sh && ./install.sh` is the clean reinstall/upgrade path when updating scripts or config logic.
- `./uninstall.sh` restores system settings and removes installed components.
- `./diagnostic.sh` collects runtime state for troubleshooting.
- `./test_config.sh` validates `~/.sleepmanager.conf` parsing and variables.
- `./sleeplog` (or `sleeplog` after install) shows recent sleep/wake summaries; `sleeplog stats [scope]` prints aggregates.
- `sleeplog stats today` limits the stats output to the current date; `battery`, `apps`, and `kills` accept `last|today|yesterday|week`.
- `./config_editor` opens the interactive config editor; after install use `sleepconf`.
- `./SleepManager.1m.sh` is a minute-based monitor; run manually when validating scheduled behavior.
- `cat ~/.sleepmanager.conf` verifies the active config values written by the installer.

## Coding Style & Naming Conventions
- Language: Bash (`#!/bin/bash`) with 4-space indentation and POSIX-friendly quoting.
- Use uppercase variable names for config/environment values (example: `CPU_THRESHOLD`).
- Keep filenames lowercase for scripts unless part of a named utility (example: `SleepManager.1m.sh`).
- No formatter or linter is currently enforced; keep changes consistent with surrounding style.

## Testing Guidelines
- There is no automated test suite; validation is manual.
- Use `./test_config.sh` after changes to config parsing or install flow.
- When editing sleep/wake logic, verify behavior with `sleeplog` and real sleep/wake cycles.

## Architecture Overview
- `sleep` runs on sleep events (via sleepwatcher) to adjust system settings, manage processes, and log.
- `wakeup` runs on wake events to restore state, unfreeze apps, and finalize log entries.
- `sleeplog` formats the log output and aggregates statistics for quick checks.
- `~/.sleepmanager.conf` is the single source of truth for thresholds, whitelists, and heavy apps.
- Logging format includes per-cycle fields like battery on close/open, awake time, usage delta, and `DELTA SLEEP` percent.
- Process-freeze behavior uses SIGSTOP at sleep and SIGCONT at wake for selected drivers/security apps to avoid restart loops.

## Commit & Pull Request Guidelines
- Commit messages follow a simple convention like `feat: ...` in Italian (see `git log`).
- Prefer small, focused commits (one feature or fix per commit).
- PRs should include: a short summary, how to test (commands run), and any macOS version notes.

## Security & Configuration Tips
- This project touches system power settings; document any changes to `pmset` defaults in PRs.
- Remind users to grant Full Disk Access to `sleepwatcher` when functionality depends on it.
- For troubleshooting, capture current power settings (`pmset -g custom`) before changes and compare after install/uninstall.
