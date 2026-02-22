# macOS Sleep Manager

macOS Sleep Manager is a lightweight set of Bash scripts that improves standby behavior on MacBooks by enforcing deep sleep, logging real battery usage, and managing processes that prevent the system from sleeping correctly.

## Features

- Deep sleep optimization with reduced dark wakes.
- Transparent logging for sleep/wake cycles and real usage time.
- Automatic handling of heavy apps and user-defined whitelists.
- Restore apps at wake/login (best effort), including Terminal working directories.
- SwiftBar menu for quick status, configuration, and tools.
- Aggregated app-list controls with add/reset from running apps or `/Applications`.

## Requirements

- macOS with `sleepwatcher` installed.
- Permissions for `sleepwatcher` (Full Disk Access recommended).

Install dependency:

```bash
brew install sleepwatcher
```

## Install

```bash
git clone https://github.com/dedandy/macos-sleep-manager.git
cd macos-sleep-manager
chmod +x install.sh
./install.sh
```

After install:

```bash
source ~/.zshrc
```

## Quick Start

- View recent events:
  ```bash
  sleeplog
  ```
- Show stats:
  ```bash
  sleeplog stats
  sleeplog stats today
  ```
- Advanced filters:
  ```bash
  sleeplog last
  sleeplog yesterday
  sleeplog week
  sleeplog battery today
  sleeplog apps week
  sleeplog kills week
  ```
- Edit configuration interactively:
  ```bash
  sleepconf
  ```
  Available list actions include add/reset from running apps, add/reset from `/Applications`, and full list clear.

## Configuration

The active configuration is written to:

```bash
~/.sleepmanager.conf
```

Key options include:

- `ENABLE_NOTIFICATIONS=true|false`
- `SAFE_QUIT_MODE=true|false`
- `CPU_THRESHOLD=1.0`
- `STANDBY_DELAY_MINUTES=60`
- `DISABLE_DARKWAKE_FEATURES=true`
- `FORCE_SLEEP_KILL_APPS="WhatsApp|Google Chrome"`
- `WHITELIST="App A|App B"`
- `HEAVY_APPS="App A|App B"`
- `RESTORE_APPS="Google Chrome|Visual Studio Code|WebStorm|Microsoft Teams|WireGuard|Docker|Terminal"`
- `RESTORE_TERMINAL_MAX=6`
- `LOG_ASSERTIONS=true`
- `TOGGLE_BLUETOOTH_ON_SLEEP=false`
- `AGGRESSIVE_POWER_PROFILE=false`
- `SHOW_STANDBY_ALERT=true`

## Restore Apps (Wake + Login)

The restore workflow runs on wake and at login via a LaunchAgent. It reopens selected apps and restores Terminal working directories when no Terminal window is open.

You can tune standby delay to improve short wakeups (example: 15, 30, 60, 120 minutes).

To reduce standby drain, you can disable dark-wake features during sleep (powernap, womp, ttyskeepawake, sleepservices).
You can also force-kill specific apps that keep assertions (example: WhatsApp, Chrome).
`sleeplog` shows a warning banner when blocking assertions are detected from diagnostics.
You can enable a more aggressive power profile (disksleep + autopoweroff) and toggle Bluetooth off during sleep.
An optional standby alert reminds you to disconnect power and USB hubs for best sleep.

Manual run:

```bash
~/.sleepmanager_restore --manual
```

## SwiftBar Menu

Copy the SwiftBar script into the plugin folder to enable the menu:

```bash
cp SleepManager.1m.sh ~/SwiftBar-Plugins/
```

If you prefer symlinks and SwiftBar does not detect them, use the copy command above.

New SwiftBar entries:
- `🧩 Gestione Liste App`: centralized controls for `WHITELIST`, `HEAVY_APPS`, `RESTORE_APPS`.
- `🔄 Refresh Ora`: immediate menu refresh after editing config from terminal.

## Installed Files

| Purpose | Path |
| --- | --- |
| Sleep hook | `~/.sleep` |
| Wake hook | `~/.wakeup` |
| Log viewer | `~/.sleeplog` |
| Config editor | `~/.sleepmanager_editor` |
| Auto editor helper | `~/.config_editor_auto` |
| Restore script | `~/.sleepmanager_restore` |
| Config file | `~/.sleepmanager.conf` |
| History log | `~/.sleeplog_history` |
| Battery snapshot | `~/.sleep_batt_start` |
| Wake info | `~/.wake_batt_info` |
| Killed apps list | `~/.sleep_killed_apps` |
| Terminal dirs cache | `~/.sleepmanager_terminal_dirs` |
| Login LaunchAgent | `~/Library/LaunchAgents/com.sleepmanager.restore.plist` |

## Troubleshooting

- Check current power settings before and after install:
  ```bash
  pmset -g custom
  ```
- Inspect logs:
  ```bash
  tail -n 100 ~/.sleeplog_history
  ```
- Verify configuration:
  ```bash
  ./test_config.sh
  ```

## FAQ

**SwiftBar plugin does not show**

- Ensure the plugin is a real file (not a symlink) inside `~/SwiftBar-Plugins`.
- Run it manually to confirm output:
  ```bash
  ~/SwiftBar-Plugins/SleepManager.1m.sh
  ```

**Apps do not restore on wake/login**

- Check `RESTORE_APPS` in `~/.sleepmanager.conf`.
- Verify the LaunchAgent:
  ```bash
  launchctl list | grep com.sleepmanager.restore
  ```

**Logs are empty or not updating**

- Confirm `sleepwatcher` has Full Disk Access.
- Make sure hooks are installed in `~/.sleep` and `~/.wakeup`.

**I ran install and lost my custom lists**

- `./install.sh` now preserves existing values from `~/.sleepmanager.conf` and only fills missing keys.
- Each install creates a backup file: `~/.sleepmanager.conf.backup-YYYYmmdd-HHMMSS`.

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## License

MIT License.
