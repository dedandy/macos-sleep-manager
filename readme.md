# macOS Sleep Manager

macOS Sleep Manager is a small Bash toolkit for Mac laptops. It monitors sleep/wake cycles, records battery changes, reduces avoidable dark wakes, manages selected applications, and exposes useful actions through SwiftBar.

It changes macOS power settings. Read configuration and troubleshooting before enabling aggressive options.

## Features

- Sleep/wake hooks triggered by `sleepwatcher`.
- Battery and session history in `~/.sleeplog_history`.
- Separate reports for active usage and sleep loss.
- Optional dark-wake reduction.
- Whitelist, heavy-app, force-kill, restore, and quick-launch lists.
- Best-effort app and Terminal restoration after wake or login.
- Compact SwiftBar menu for status, reports, list editing, and quick actions.
- Diagnostic snapshots for `pmset` assertions and sleep/wake events.

## Requirements

- macOS and Homebrew.
- `sleepwatcher`:

~~~~bash
brew install sleepwatcher
~~~~

Grant Full Disk Access to the process used by `sleepwatcher` if hooks do not run reliably. Some actions also need Automation permissions for Terminal, Finder, and System Events.

## Install

~~~~bash
git clone https://github.com/dedandy/macos-sleep-manager.git
cd macos-sleep-manager
chmod +x install.sh
./install.sh
source ~/.zshrc
~~~~

The installer copies hooks and utilities, detects common applications, creates or updates `~/.sleepmanager.conf`, preserves existing values during upgrades, creates a timestamped backup, configures `pmset` and `sleepwatcher`, installs the restore LaunchAgent, and adds shell aliases.

Verify installation:

~~~~bash
./diagnostic.sh
./test_config.sh
cat ~/.sleepmanager.conf
~~~~

## How to use

### 1. Check status

~~~~bash
./diagnostic.sh
pmset -g custom
pmset -g assertions
~~~~

### 2. Read sleep history

~~~~bash
sleeplog
sleeplog last
sleeplog today
sleeplog yesterday
sleeplog week
sleeplog stats
sleeplog stats today
sleeplog battery week
sleeplog apps week
sleeplog kills week
~~~~

Fields:

- `BATT`: battery level captured at sleep or wake.
- `AWAKE`: active minutes since previous wake.
- `USED`: battery consumed during active use. Charging is reported as zero usage.
- `DELTA`: battery lost during sleep. Charging is reported as zero sleep loss.
- Assertion warnings identify processes or devices that may interfere with sleep.

### 3. Configure application lists

Open the interactive editor:

~~~~bash
sleepconf
~~~~

SwiftBar offers one compact `Modifica` action for each list. Lists use `|` as separator:

~~~~bash
WHITELIST="Music|Spotify|IINA"
HEAVY_APPS="Google Chrome|Firefox"
FORCE_SLEEP_KILL_APPS="WhatsApp|Google Chrome"
RESTORE_APPS="Google Chrome|Visual Studio Code|Terminal"
QUICK_LAUNCH_APPS="Safari|Notes"
~~~~

- `WHITELIST`: protects an app from normal aggressive cleanup.
- `HEAVY_APPS`: apps that may be closed at sleep and restored according to power state.
- `FORCE_SLEEP_KILL_APPS`: always killed at sleep; keep this list minimal.
- `RESTORE_APPS`: apps reopened at wake or login when not already running.
- `QUICK_LAUNCH_APPS`: apps started together by `quicklaunch`.

### 4. Choose a sleep profile

Recommended starting point:

~~~~bash
PRESERVE_APP_SESSIONS=true
DISABLE_DARKWAKE_FEATURES=true
STANDBY_DELAY_MINUTES=15
AGGRESSIVE_POWER_PROFILE=false
~~~~

For long absences, disconnect USB hubs, disks, docks, and unnecessary peripherals. Test one setting at a time and compare:

~~~~bash
sleeplog battery week
pmset -g log | tail -n 100
~~~~

| Option | Effect | Starting value |
| --- | --- | --- |
| `PRESERVE_APP_SESSIONS` | Keeps normal app sessions alive | `true` |
| `DISABLE_DARKWAKE_FEATURES` | Reduces background wake services | `true` |
| `STANDBY_DELAY_MINUTES` | Delay before standby transition | `15` |
| `FORCE_SLEEP_KILL_APPS` | Always kills listed apps | Empty/minimal |
| `LOG_ASSERTIONS` | Stores power assertions | `true` |
| `TOGGLE_BLUETOOTH_ON_SLEEP` | Turns Bluetooth off/on; needs `blueutil` | `false` |
| `AGGRESSIVE_POWER_PROFILE` | Enables short disk sleep/autopoweroff | `false` |
| `SHOW_STANDBY_ALERT` | Reminds about power and USB devices | `true` |

### 5. Use SwiftBar

Install SwiftBar separately, then copy the plugin:

~~~~bash
mkdir -p ~/SwiftBar-Plugins
cp SleepManager.1m.sh ~/SwiftBar-Plugins/
~~~~

The compact menu contains current delta, quick launch, immediate sleep, list editing, log reports, settings toggles, the full editor, and manual app restore.

If SwiftBar does not detect the file, use a real copy rather than a symlink and run it manually:

~~~~bash
~/SwiftBar-Plugins/SleepManager.1m.sh
~~~~

### 6. Launch or restore apps

~~~~bash
quicklaunch
~/.sleepmanager_restore --manual
~~~~

Already running apps are skipped. Terminal directories are restored only when Terminal has no existing windows, up to `RESTORE_TERMINAL_MAX` entries.

## Configuration reference

The active file is `~/.sleepmanager.conf`:

~~~~bash
ENABLE_NOTIFICATIONS=true
SAFE_QUIT_MODE=true
CPU_THRESHOLD=1.0
STANDBY_DELAY_MINUTES=15
PRESERVE_APP_SESSIONS=true
DISABLE_DARKWAKE_FEATURES=true
FORCE_SLEEP_KILL_APPS="WhatsApp|Google Chrome"
WHITELIST="Music|Spotify"
HEAVY_APPS="Google Chrome|Firefox"
RESTORE_APPS="Google Chrome|Visual Studio Code|Terminal"
QUICK_LAUNCH_APPS="Safari|Notes"
RESTORE_TERMINAL_MAX=6
LOG_ASSERTIONS=true
TOGGLE_BLUETOOTH_ON_SLEEP=false
AGGRESSIVE_POWER_PROFILE=false
SHOW_STANDBY_ALERT=true
~~~~

## Installed files

| Purpose | Path |
| --- | --- |
| Sleep hook | `~/.sleep` |
| Wake hook | `~/.wakeup` |
| Log viewer | `~/.sleeplog` |
| Main editor | `~/.sleepmanager_editor` |
| List editor | `~/.config_editor_auto` |
| Restore script | `~/.sleepmanager_restore` |
| Quick launch | `~/.quicklaunch` |
| Configuration | `~/.sleepmanager.conf` |
| History log | `~/.sleeplog_history` |
| Diagnostic log | `~/.sleepmanager_diagnose` |
| Sleep battery snapshot | `~/.sleep_batt_start` |
| Wake battery info | `~/.wake_batt_info` |
| Login LaunchAgent | `~/Library/LaunchAgents/com.sleepmanager.restore.plist` |

## Troubleshooting

### Hooks do not run

~~~~bash
brew services list | grep sleepwatcher
ls -l ~/.sleep ~/.wakeup ~/.sleeplog
./diagnostic.sh
brew services restart sleepwatcher
~~~~

Confirm Full Disk Access and Automation permissions.

### Battery drains with the lid closed

Capture evidence:

~~~~bash
pmset -g custom
pmset -g assertions
pmset -g log | tail -n 100
sleeplog battery week
~~~~

Look for `DarkWake`, `Wake from`, `ExternalMedia`, USB devices, network assertions, or repeated wake events. Disconnect docks and hubs for the next test.

### Apps are killed too often

~~~~bash
grep -E 'FORCE_SLEEP_KILL_APPS|HEAVY_APPS|PRESERVE_APP_SESSIONS' ~/.sleepmanager.conf
sleeplog apps week
~~~~

Force-kill has priority over normal session preservation.

### Apps do not restore

~~~~bash
grep '^RESTORE_APPS=' ~/.sleepmanager.conf
launchctl list | grep com.sleepmanager.restore
~/.sleepmanager_restore --manual
~~~~

### Upgrade safely

Run `./install.sh` again. Existing values are preserved and a timestamped backup is created. Avoid `uninstall.sh` for normal upgrades because it removes logs and configuration.

## Uninstall

~~~~bash
./uninstall.sh
~~~~

Back up `~/.sleepmanager.conf` and `~/.sleeplog_history` first if you need them later.

## Development checks

~~~~bash
for file in sleep wakeup sleeplog SleepManager.1m.sh install.sh diagnostic.sh config_editor config_editor_auto quicklaunch restore_apps.sh test_config.sh; do
    bash -n "$file" || exit 1
done
./test_config.sh
git diff --check
~~~~

Real sleep/wake behavior must be verified on macOS; syntax checks cannot validate power-management events.

## License

MIT License.
